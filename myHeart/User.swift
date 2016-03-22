//
//  User.swift
//  Confidential
//
//  Created by Bhaskar Rajbongshi on 5/12/15.
//  Copyright (c) 2015 AMGEN. All rights reserved.
//

import Foundation

let kSavedUser: String = "SavedUser"

@objc (User)
class User: CMUser {
    
    dynamic var createdDate: NSDate?
    dynamic var id: String?
    dynamic var vId: String?
    dynamic var vUserToken:String?
    
    /*
    
    "__class__": "Enrollment",
    "uId": "56b918002604cea53e0000b3",
    "code": "ABCDEFG",
    "isActivated": true,
    "activationDTTM": 1457631518487,
    "validicId": "56b918002604cea53e0000b3",
    "userToken": "uNzih6vMsUKzE5MidjcY",
    "firstName": "Bala",
    "lastName": "Krishnapillai",
    "email": "bala.krishnapillai@gmail.com",
    "lastSyncDTTM": "",
    "isConsented": false,
    "consentDTTM": ""
    
    
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        id = aDecoder.decodeObjectForKey("id") as! String?
        vId = aDecoder.decodeObjectForKey("vId") as! String?
        vUserToken = aDecoder.decodeObjectForKey("vUserToken") as! String?
        createdDate = aDecoder.decodeObjectForKey("createdDate") as! NSDate?
    }
    
    override init() {
        super.init()
    }
    
    override init!(email theEmail: String!, andUsername theUsername: String!, andPassword thePassword: String!) {
        super.init(email: theEmail, andUsername: theEmail, andPassword: thePassword)
    }
    
    convenience init!(email theEmail: String!, andUserId theUserId: String!, andPassword thePassword: String!) {
        self.init(email: theEmail, andUsername: theEmail, andPassword: thePassword)
        //uId = theUserId
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(vId, forKey: "vId")
        aCoder.encodeObject(vUserToken, forKey: "vUserToken")
        aCoder.encodeObject(createdDate, forKey: "createdDate")
    }
    
    func saveToUserDefault() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(self)
        defaults.setObject(data, forKey: kSavedUser)
        defaults.synchronize()
    }
    
    class func savedUser() -> User? {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var savedUserdata: User?
        if let data = defaults.objectForKey(kSavedUser) as? NSData {
            savedUserdata =  NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User?
        }
        return savedUserdata
    }
    
    class func clearUser() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(kSavedUser)
        defaults.synchronize()
    }
    
}

