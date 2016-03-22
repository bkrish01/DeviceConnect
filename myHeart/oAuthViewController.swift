//
//  ViewController.swift
//  Clinical Trials
//
//  Created by Krishnapillai, Bala on 2/1/16.
//  Copyright © 2016 AMGEN. All rights reserved.
//

import UIKit
import WebKit
import ResearchKit
import MessageUI

class oAuthViewController: UIViewController, UITextFieldDelegate {
    lazy var regCallback: CMUserOperationCallback? = nil
    
    var user: User?
    
    @IBOutlet weak var LblAssocDevice: UILabel!
    @IBOutlet weak var TxtFirstName: UITextField!
    @IBOutlet weak var TxtLastName: UITextField!
    @IBOutlet weak var TxtEmail: UITextField!
    @IBOutlet weak var TxtPassword: UITextField!
//    @IBOutlet weak var TxtFirstName: UITextField!
//    @IBOutlet weak var TxtLastName: UITextField!
    
    var app_name: String!
    var app_url: String!
    var sync_stat: String!
    var devicename: String!
    var logo:String!
    var activationCode: String!
    var userUID:  String!
    //var user_UID :String!
    var userId : String = String()
    var vuserToken : String = String()
    var ConstructURL: String = String()
    var userInfoDic : NSMutableDictionary!
   
//    @IBAction func Enrollment(sender: AnyObject){
//        let userInfoDic = NSMutableDictionary()
//        userInfoDic.setValue(self.TxtFirstName.text, forKey: "firstName")
//        userInfoDic.setValue(self.TxtLastName.text, forKey: "lastName")
//        userInfoDic.setValue(self.TxtEmail.text, forKey: "email")
//        userInfoDic.setValue(self.TxtPassword.text, forKey: "password")
//        
//        print("UserDicionary:\(userInfoDic)")
//        
//        self.createUser(userInfoDic)
//        let storyboard = UIStoryboard(name: "Main", bundle:nil)
//        let secondView = self.storyboard!.instantiateViewControllerWithIdentifier("RegisterView") as! UINavigationController
//         self.presentViewController(secondView, animated: true, completion: nil)
//
//        
//    }

    
        @IBAction func Enrollment(sender: AnyObject){
            
            self.user = User(email: self.TxtEmail?.text, andUsername: self.TxtEmail.text, andPassword: self.TxtPassword?.text)!
            print("self.user is: \(self.user!.username)")
            self.user!.createAccountWithCallback(self.regCallback)
    
//            self.createUser(userInfoDic)
//            let storyboard = UIStoryboard(name: "Main", bundle:nil)
//            let secondView = self.storyboard!.instantiateViewControllerWithIdentifier("RegisterView") as! UINavigationController
//             self.presentViewController(secondView, animated: true, completion: nil)
//    
            
        }
    
    func displayMyAlertMessage(userMessage :String)
    {
        var myAlert = UIAlertController(title: "Login Error",  message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil);
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
                print("Account Created Successfully \(messages)")
                self.updateUser()
                self.user!.loginWithCallback(self.regCallback)
                break
                
            case .CreateFailedDuplicateAccount:
                self.displayMyAlertMessage("Looks like you are an exsting member! \r\n Please go to login page and enter your valid Credentials!")
                break
                
            case .LoginSucceeded:
                self.ProvisionVUser()
                let storyboard = UIStoryboard(name: "Main", bundle:nil)
                let secondView = storyboard.instantiateViewControllerWithIdentifier("RegisterView") as! UINavigationController
                self.presentViewController(secondView, animated: true, completion: nil)
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
        self.user!.createdDate = NSDate()
        self.user!.id =  self.user!.objectId
        if let vId = NSUserDefaults.standardUserDefaults().valueForKey("_id")
        {
            self.user!.vId = vId as! String
        }
        else
        {
            
            self.user!.vId = nil
        }
        if let vUserToken = NSUserDefaults.standardUserDefaults().valueForKey("ValidicUserAccessToken")
        {
            self.user!.vUserToken = vUserToken as! String
        }else{
            self.user!.vUserToken = nil
 
        }
        
        CMStore.defaultStore().user = self.user
        CMStore.defaultStore().user.save(self.regCallback)
        print("user id is: \(self.user!.id) , \(self.user!.vUserToken), \(self.user!.vId)")
    }
    
    func ProvisionVUser()
    {
        if let userUID = self.user!.id
        {
            print("Cloudmine UID\(userUID)")
            let validicUserObject = NSMutableDictionary()
            let validicUserInfoDic = NSMutableDictionary()
            validicUserInfoDic.setObject("fd63d2852e1c4e099d17fea2095fc154d0331e87f31f44325eeffdc4662a1d9a", forKey: "access_token")
            validicUserObject.setObject(userUID, forKey: "uid")
            validicUserInfoDic.setObject(validicUserObject, forKey: "user")
            print("Validic Dict :\(validicUserInfoDic)")
            self.ProvisionUser_Valdiic(validicUserInfoDic)
       
        }
    }
    
    
    @IBAction func CancelOperation(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TxtFirstName.delegate = self
        self.TxtLastName.delegate = self
        self.TxtPassword.delegate = self
        self.TxtEmail.delegate = self
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func createUser(userNameDictionary : NSDictionary)
//    {
////        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.cloudmine.me/v1/app/28885ce6bcf84894a485a67835eba1fa/run/createMCTUser?apikey=0a1b4806f62c41789856025175e70fe5")!)
//
//        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.cloudmine.me/v1/app/ca21bdf52cbd492d8be3c94fa273a756/run/createNewUser?apikey=8dd5bbb87c6646f18494ce7adf98dfe1")!)
//
//        let session = NSURLSession.sharedSession()
//        request.HTTPMethod = "POST"
//        do {
//            let jsonData = try NSJSONSerialization.dataWithJSONObject(userNameDictionary, options: NSJSONWritingOptions.PrettyPrinted)
//            print("JSON Data = \(jsonData)")
//            print("JSON String \(String(data: jsonData, encoding: NSUTF8StringEncoding))")
//            request.HTTPBody = jsonData
//            
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            
//            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//                print("Response: \(response)")
//                print("Response String \(String(data: data!, encoding: NSUTF8StringEncoding))")
//                self.parseResponse(data!)
//                if let userUID = NSUserDefaults.standardUserDefaults().valueForKey("UserId")
//                    {
//                        print("Cloudmine UID\(userUID)")
//                        let validicUserObject = NSMutableDictionary()
//                        let validicUserInfoDic = NSMutableDictionary()
//                        validicUserInfoDic.setObject("fd63d2852e1c4e099d17fea2095fc154d0331e87f31f44325eeffdc4662a1d9a", forKey: "access_token")
//                        validicUserObject.setObject(userUID, forKey: "uid")
//                        validicUserInfoDic.setObject(validicUserObject, forKey: "user")
//                        print("Validic Dict :\(validicUserInfoDic)")
//                        self.ProvisionUser_Valdiic(validicUserInfoDic)
//                    }
//        })
//            task.resume()
//            
//        } catch let error as NSError{
//            print(" Create User Error:\(error)")
//        }
//        
//    }
//    
//    func parseResponse(responseData : NSData)
//    {
//        do {
//            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
//            print("jsonDictionary\(jsonDictionary)")
//            NSUserDefaults.standardUserDefaults().setValue(jsonDictionary.objectForKey("result")?.objectForKey("data")?.objectForKey("uId"), forKey: "UserId")
//        } catch let error as NSError {
//            print("json error: \(error.localizedDescription)")
//        }
//        
//    }
//    
    
    
    func ProvisionUser_Valdiic(ValidicuserDict: NSMutableDictionary)
    {
        let validicrequest = NSMutableURLRequest(URL: NSURL(string: "https://api.validic.com/v1/organizations/5412de4e965fe22a1c000149/users.json")!)
        let validicsession = NSURLSession.sharedSession()
        validicrequest.HTTPMethod = "POST"
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(ValidicuserDict, options: NSJSONWritingOptions.PrettyPrinted)
            validicrequest.HTTPBody = jsonData
            validicrequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            validicrequest.addValue("application/json", forHTTPHeaderField: "Accept")
            let task = validicsession.dataTaskWithRequest(validicrequest, completionHandler: {data, response, error -> Void in
                print("Validic Response String \(String(data: data!, encoding: NSUTF8StringEncoding))")
                self.parseValidicResponse(data!)
                dispatch_async(dispatch_get_main_queue(),{
                    //self.dismissAndPresentTaskVC()
                })
            })
          task.resume()
            
        } catch let error as NSError {
            //dismissAndPresentTaskVC()
            print(error)
        }
        
        
      

    }
    
    func parseValidicResponse(responseData : NSData)
    {
        do {
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            // use anyObj here
            NSUserDefaults.standardUserDefaults().setValue(jsonDictionary.objectForKey("user")?.objectForKey("_id"), forKey: "_id")
            NSUserDefaults.standardUserDefaults().setValue(jsonDictionary.objectForKey("user")?.objectForKey("access_token"), forKey: "ValidicUserAccessToken")
        }
        catch let error as NSError {
            print("Validic json response error: \(error.localizedDescription)")
        }
        // Update Cloudmine User Profile
        print("Updating User Profile with VID + VTOKEN Details")
        updateUser()
        
    }
   
    
  func textFieldShouldReturn(TxtPassword : UITextField) -> Bool {
        TxtPassword.resignFirstResponder()
        return true;
    }
  
    

}