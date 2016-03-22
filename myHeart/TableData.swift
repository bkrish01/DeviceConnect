//
//  TableData.swift
//  DevCon
//
//  Created by Krishnapillai, Bala on 2/19/16.
//  Copyright © 2016 AMGEN. All rights reserved.
//

import Foundation
import UIKit

class TableData{
    
    /*
    [["elevation": <null>, "utc_offset": -08:00, "water": 0, "floors": <null>, "timestamp": 2016-02-16T08:00:00+00:00, "last_updated": 2016-02-16T21:12:41+00:00, "source": fitbit, "validated": 0, "distance": 1620.88, "_id": 56c361ebb6182240d20655cb, "calories_burned": 1223, "steps": 2164, "source_name": Fitbit]]
    */
    var elevation : NSString!
    var utc_offset :NSString!
    var water :NSString!
    var floors :NSString!
    var timestamp :NSString!
    var last_updated :NSString!
    var source :NSString!
    var validated :NSString!
    var distance :NSString!
    var _id :NSString!
    var calories_burned :NSString!
    var steps :NSString!
    var source_name :String!
    // MARK: Initialization
    
    init?(source_name: String, steps: String, status: String) {
        // Initialize stored properties.
        self.source_name = source_name
        self.steps = steps
        self.validated = status
        
        // Initialization should fail if there is no name or if the rating is negative.
        if source_name.isEmpty || source_name.isEmpty {
            return nil
        }
    }
    
    
    init?(source_data: NSDictionary) {
        // Initialize stored properties.
        self.source_name = source_data["source_name"]! as! String
        self.steps = source_data["steps"]! as! String
        self.validated = source_data["validated"]! as! String
        
        // Initialization should fail if there is no name or if the rating is negative.
        if source_name.isEmpty || source_name.isEmpty {
            return nil
        }
    }

    
    
}
