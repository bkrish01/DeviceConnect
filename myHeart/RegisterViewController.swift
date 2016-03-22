//
//  RegisterViewController.swift
//  Patient ePRO
//
//  Created by Krishnapillai, Bala on 2/17/16.
//  Copyright © 2016 AMGEN. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import ResearchKit
import MessageUI


class RegisterViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var MyLogin: UIWebView!
    @IBOutlet weak var MyActivityIndicator: UIActivityIndicatorView!
    
    @IBAction func Done(sender: AnyObject) {
         self.MyLogin.reload()
        //self.dismissViewControllerAnimated(true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        self.presentViewController( storyboard.instantiateInitialViewController()!, animated: true, completion: nil)
    }
    
    
    @IBAction func Refresh(sender: AnyObject) {
        self.MyLogin.reload()
    }
    @IBAction func Back(sender: AnyObject) {
        
        if self.MyLogin.canGoBack{
           self.MyLogin.goBack()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MyLogin.delegate = self
        print (NSUserDefaults.standardUserDefaults().valueForKey("ValidicUserAccessToken"))
        if let AuthToken = NSUserDefaults.standardUserDefaults().valueForKey("ValidicUserAccessToken")
        {
        print ("VAcessToken=\(AuthToken)")
        //let myURL = NSURL(string: "https://app.validic.com/organizations/5412de4e965fe22a1c000149/auth/fitbit?user_token=\(VIDToken)&format_redirect=json&redirect_uri=https://dth.cloudmineapp.com")!
        let myURL = NSURL(string: "https://app.validic.com/5412de4e965fe22a1c000149/\(AuthToken)")!
        //let myURL = NSURL(string: "https://app.validic.com/organizations/5412de4e965fe22a1c000149/auth/fitbit?user_token=\(AuthToken)&format_redirect=json&redirect_uri=https://confirm.cloudmineapp.com/")!
        MyLogin.loadRequest(NSURLRequest(URL: myURL))
        self.MyLogin.scalesPageToFit = true
        self.MyLogin.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(MyLogin)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webViewDidStartLoad(webView: UIWebView)
    {
         MyActivityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
         MyActivityIndicator.stopAnimating()
    }
 
    
    
}
