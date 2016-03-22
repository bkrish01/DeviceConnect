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

class RegisterationViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var MyLogin: UIWebView!
    @IBOutlet weak var MyActivityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = NSURL(fileURLWithPath: "http://www.gmail.com")
        print ("Construct UR::\(myURL)")
        let myURLRequest:NSURLRequest = NSURLRequest(URL: myURL)
        MyLogin.loadRequest(myURLRequest)
        MyLogin.hidden = false
        self.view.addSubview(MyLogin)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        MyActivityIndicator.startAnimating()
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        print(" Webivew Loading Timestamp = \(formatter.stringFromDate(date))")
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        MyActivityIndicator.stopAnimating()
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        print(" Webivew Finishing loading Timestamp = \(formatter.stringFromDate(date))")
    }
    
}
