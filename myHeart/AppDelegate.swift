//
//  AppDelegate.swift
//  myHeart
//
//  Created by Shashank Kothapalli on 8/21/15.
//  Copyright (c) 2015 Amgen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        NSThread.sleepForTimeInterval(0.5);
        
        let credentials: CMAPICredentials = CMAPICredentials.sharedInstance() as CMAPICredentials
            credentials.appIdentifier = "ca21bdf52cbd492d8be3c94fa273a756"
            credentials.appSecret = "8dd5bbb87c6646f18494ce7adf98dfe1"
            
        // New Relic Agent Name : MCT- Vitals
        //NewRelicAgent.startWithApplicationToken("AAd2fa396c52319dd34f8f25f07e64bcdf4fefccfc");
        //NewRelicAgent.startWithApplicationToken("e7be0ba6aaff818b6cb36d2e55a6e47a348b0152");
        NewRelicAgent.startWithApplicationToken("AAa6d3582bb7285d1003e1bde5b9103e60d832689f");
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

