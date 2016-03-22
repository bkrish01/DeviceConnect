//
//  HomePageViewController.swift
//  myHeart
//
//  Created by Bala Krishnapillai on 02/4/15.
//  Copyright (c) 2016 Amgen. All rights reserved.
//

import UIKit
import ResearchKit
import MessageUI

class HomePageViewController: UIViewController , UITextFieldDelegate {

    let healthManager:HealthKit = HealthKit()
  
    @IBOutlet weak var TxtCode: UITextField!
    
    lazy var regCallback: CMUserOperationCallback? = nil

    var user: User?
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.TxtCode.delegate = self
        self.passwordField.delegate = self
        self.emailAddress.delegate = self

        
        // Do any additional setup after loading the view.
        print("HomePageviewController - init load")

        
    }

    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        regCallback = { (resultCode: CMUserAccountResult, messages: [AnyObject]?) in
            if messages?.count > 0 {
                print("message: \(messages)")
                return
            }
            switch resultCode {
            case .CreateSucceeded:
                self.updateUser()
                self.user!.loginWithCallback(self.regCallback)
                break
                
            case .CreateFailedDuplicateAccount:
                print("result array  is \(messages)")
                break
                
            case .LoginSucceeded:
            //self.loginSuccessful()
                self.getUserProfile()
                break
                
            case .LoginFailedIncorrectCredentials:
                 self.displayMyAlertMessage("LoginFailed! Incorrect Credentials .Please enter your valid Credentials!")
                break
            
            default:
                break
            }
        }
    }

    func updateUser() {
        self.user!.id =  self.user!.objectId
        CMStore.defaultStore().user = self.user
        print("user id is: \(self.user!.id)")
    }
    
    
  
    func getUserProfile()
    {
        var iresult = true
        var myToken = NSUserDefaults.standardUserDefaults().valueForKey("vUserToken")
        
        print("********** User Information **************")
        print("**********__id__ = cb5d3f76bf384a52974e44bf8fa45c57")
        print("**********vUserToken = F-X1xEbGLncKpUhNjiB")
        print("**********__class__ = User")
        print("**********email = sk@sk.com")
        print("********** User Information **************")
        
        print("MYTOKEN= \(myToken)")
        //let myURL = NSURL(string: "https://api.validic.com/v1/profile.json?authentication_token=xzxTyYzuLKyr94uNakC4")
        let myURL = NSURL(string: "https://api.validic.com/v1/profile.json?authentication_token=xzxTyYzuLKyr94uNakC4")
        let myURLRequest:NSURLRequest = NSURLRequest(URL: myURL!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(myURLRequest) {
            (data, response, error) -> Void in
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)  as! NSDictionary
                    print("Json.count\(json.count)")
                    print("Validic Response String \(String(data: data!, encoding: NSUTF8StringEncoding))")
                    let routineObject = (json.objectForKey("profile")?.objectForKey("applications")?.count)! as NSInteger
                    print("count\(routineObject)")
                    if routineObject == 0
                    {
                        iresult = false
                        print("No App Association")
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            //self.displayMyAlertMessage("Hello\(self.user!.email), Looks like you didn't add your wearable device to your account!. \r\n Please add the device and grant access to view your activity data")
                            let storyboard = UIStoryboard(name: "Main", bundle:nil)
                            let secondView = storyboard.instantiateViewControllerWithIdentifier("DeviceAssoc")
                            self.presentViewController(secondView, animated: true, completion: nil)
                            
                        }
                    }
                    else{
                        iresult = true
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                        let storyboard = UIStoryboard(name: "Main", bundle:nil)
                        let secondView = self.storyboard!.instantiateViewControllerWithIdentifier("DashboardView1")
                        self.presentViewController(secondView, animated: true, completion: nil)
                        }
                    }

                }
                catch let error as NSError {
                    print("Validic json response error: \(error.localizedDescription)")
                    iresult = false
                }
            }
        }
       task.resume()
       print("iresult\(iresult)")
        

    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func lauchTaskController()
    {
        print("launch")
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let secondView = storyboard.instantiateViewControllerWithIdentifier("DashboardView1") as! UITabBarController
        self.presentViewController(secondView, animated: true, completion: nil)
 
    }

    @IBAction func registerUser(sender: AnyObject) {
        self.user = User(email: self.emailAddress?.text, andUsername: self.emailAddress.text, andPassword: self.passwordField?.text)!
        print("self.user is: \(self.user!.username)")
        //self.user!.createAccountWithCallback(self.regCallback)
        self.user!.loginWithCallback(self.regCallback)
     }
    
//    @IBAction func Login(sender: AnyObject) {
//        healthManager.authorizeHealthKit{(authorized,error) -> Void in
//            //presents the consent task if authorized
//            if authorized {
//                print ("TxtCode:\(self.TxtCode.text)")
//                let myactcode = self.TxtCode.text;
//                if (myactcode != "")
//                {   NSOperationQueue.mainQueue().addOperationWithBlock {
//
//                    self.AutheticateUser()
//                    }
//                }else{
//                    self.displayMyAlertMessage("Please enter your activation code!")
//                    return
//                }
//                
//            }
//            else {
//                if error != nil {
//                    print("Please Authorize the Healthkit to view data\(error)")
//                }
//            }
//            
//        }
//    }
//
   
    
    func displayMyAlertMessage(userMessage :String)
    {
        var myAlert = UIAlertController(title: "Login Error",  message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil);
    }
    
//    func AutheticateUser()
//    {
//
//        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.cloudmine.me/v1/app/ca21bdf52cbd492d8be3c94fa273a756/run/enrollUser?apikey=8dd5bbb87c6646f18494ce7adf98dfe1&code=" + TxtCode.text!)!)
//        let session = NSURLSession.sharedSession()
//        request.HTTPMethod = "POST"
//        
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        
//        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//            print("HTTP Response Data \(String(data: data!, encoding: NSUTF8StringEncoding))")
//            print("HTTP Response Description  \(String(Response: response!, encoding: NSUTF8StringEncoding))")
//            
//            do {
//                let responseData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
//                let userErrorObject = responseData.objectForKey("result")
//                let myStatusCode = userErrorObject!.objectForKey("statusCode")
//                let myErrorCode = userErrorObject?.objectForKey("error")
//                let myMessage  = userErrorObject?.objectForKey("message")
//                
//                print("ResponseObject:\(myStatusCode, myErrorCode, myMessage)")
//                
//                let str = String(myStatusCode)
//                
//                if(str == "Optional(500)")
//                {
//                    self.displayMyAlertMessage("Please enter a valid activation code!")
//                    return
//                }else{
//                let userData = responseData.objectForKey("result")?.objectForKey("data")
//                let userId = userData?.objectForKey("uId")
//                let validicId = userData?.objectForKey("validicId")
//                let userToken = userData?.objectForKey("userToken")
//                let orgId = userData?.objectForKey("orgId")
//                let authToken = userData?.objectForKey("authToken")
//                
//                NSUserDefaults.standardUserDefaults().setValue(userId, forKey: "UserId")
//                NSUserDefaults.standardUserDefaults().setValue(validicId, forKey: "ValidicId")
//                NSUserDefaults.standardUserDefaults().setValue(userToken, forKey: "UserToken")
//                NSUserDefaults.standardUserDefaults().setValue(orgId, forKey: "OrganizationId")
//                NSUserDefaults.standardUserDefaults().setValue(authToken, forKey: "AuthToken")
//                NSOperationQueue.mainQueue().addOperationWithBlock {
//
//                self.lauchTaskController()
//                    }
//                }
//            } catch let error as NSError {
//                print("json error: \(error.localizedDescription)")
//            }
//        })
//        task.resume()
//    }
//    
    
    func textFieldShouldReturn(passwordField : UITextField) -> Bool {
        passwordField.resignFirstResponder()
        return true;
    }
    
    @IBAction func SignUp(sender: AnyObject) {
//        if NSUserDefaults.standardUserDefaults().objectForKey("UserId") != nil
//        {
//            var myuserid = NSUserDefaults.standardUserDefaults().objectForKey("UserId")!
//            self.displayMyAlertMessage("Hello \(myuserid) !  You have an active account with us. Please login using your enrollment key. Otherwise, please contact your administrator to obtain your enrollent key!")
//            return
//        }
//        else
//        {
            // authorizes health Kit
            healthManager.authorizeHealthKit{(authorized,error) -> Void in
                //presents the consent task if authorized
                if authorized {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                    let storyboard = UIStoryboard(name: "Main", bundle:nil)
                    let secondView = self.storyboard!.instantiateViewControllerWithIdentifier("URView") as! UIViewController
                    self.presentViewController(secondView, animated: true, completion: nil)
                    }
                }
                else {
                    if error != nil {
                        print("\(error)")
                        self.displayMyAlertMessage("\(error) .Please contact your administrator to obtain your enrollent key!")
                        //            return
                    }
                }
            }
        //}
        
    }

}