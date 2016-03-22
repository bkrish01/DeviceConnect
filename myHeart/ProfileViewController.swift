//
//  ProfileViewController.swift
//  DevCon
//
//  Created by Krishnapillai, Bala on 3/4/16.
//  Copyright © 2016 AMGEN. All rights reserved.
//

import UIKit
import ResearchKit
import MessageUI

class ProfileViewController: UIViewController {
    let healthManager:HealthKit = HealthKit()
    
    @IBOutlet weak var vName: UILabel!
    
    @IBOutlet weak var vGender: UILabel!
    
    @IBOutlet weak var VDeviceme: UILabel!
    
    @IBOutlet weak var VdevType: UILabel!
    
    @IBOutlet weak var vDevSer: UILabel!
    
    @IBOutlet weak var Lblsynstatus: UILabel!
    @IBAction func syncnow(sender: AnyObject) {
        
    }
    
    @IBOutlet weak var vDevType: UILabel!
    
    
    @IBOutlet weak var VLast_upd: UILabel!
    
    lazy var regCallback: CMUserOperationCallback? = nil

    //MARK: Properties
    
    var UserId,ValidicId,UserToken,OrganizationId,AuthToken : String!
    var myResult: NSDictionary!
    var routineRecord :NSDictionary!
    var dashboards = [Dashboard]()
    var tabledata = [TableData]()
    var stepsdic : NSDictionary!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        regCallback = { (resultCode: CMUserAccountResult, messages: [AnyObject]?) in
            if messages?.count > 0 {
                print("message: \(messages)")
                return
            }
            switch resultCode {
            case .CreateSucceeded:
//                self.updateUser()
//                self.user!.loginWithCallback(self.regCallback)
//                NSUserDefaults.standardUserDefaults().setBool(true, forKey: KOverlayHintStatus)
                break
                
            case .CreateFailedDuplicateAccount:
//                self.activityIndi.hideActivityIndicator(self.navigationController!.view)
                print("result array  is \(messages)")
//                PXAlertView.showAlertWithTitle("Sign In Failed", message: "The username already exists. Please Try Again.")
                break
                
            case .LoginSucceeded:
//                self.loginSuccessful()
                break
                
            default:
//                self.showAlert("Network Unavailable")
//                self.activityIndi.hideActivityIndicator(self.navigationController!.view)
                break
            }
        }
    }
    

    
    @IBAction func JobDone(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        GetUserProfile("https://api.validic.com/v1/profile.json?authentication_token=\(String(NSUserDefaults.standardUserDefaults().valueForKey("UserToken")!))")
//        
//        GetUserProfile("https://api.validic.com/v1/profile.json?authentication_token=5F5eyDMd-x7m1k7qXLz2")
        
        
     
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    func GetUserProfile(sURL: NSString)
    {
        print ("URL:\(sURL)")
        
        let myURL = NSURL(string: sURL as String)
        let myURLRequest:NSURLRequest = NSURLRequest(URL: myURL!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(myURLRequest) {
            (data, response, error) -> Void in
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)  as! NSDictionary
                    self.vName.text = json.objectForKey("profile")?.objectForKey("uid") as! String
                    self.vGender.text = json.objectForKey("profile")?.objectForKey("gender") as! String
                    let vbatStrength = json.objectForKey("profile")?.objectForKey("devices")?.objectForKey("fitbit")?.objectForKey("199551944")?.objectForKey("battery") as! String
                    self.vDevSer.text = json.objectForKey("profile")?.objectForKey("devices")?.objectForKey("fitbit")?.objectForKey("199551944")?.objectForKey("id") as! String
                    self.vDevType.text = json.objectForKey("profile")?.objectForKey("devices")?.objectForKey("fitbit")?.objectForKey("199551944")?.objectForKey("type") as! String
                    self.VLast_upd.text = json.objectForKey("profile")?.objectForKey("devices")?.objectForKey("fitbit")?.objectForKey("199551944")?.objectForKey("last_sync_time") as! String
                    
                }
                catch let error as NSError {
                    print("Validic json response error: \(error.localizedDescription)")
                }
                
            }
            
        }
        task.resume()
    }
    
    
    
    
    @IBAction func Done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

  