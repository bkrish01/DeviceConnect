//
//  Dashboard.swift
//  Patient ePRO
//
//  Created by Krishnapillai, Bala on 2/10/16.
//  Copyright © 2016 AMGEN. All rights reserved.
//

import Foundation
import UIKit

class Dashboard {
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var validated: Bool
    var steps: Int
    var calories: Int
    var distance: Double
    var last_upd: String
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, validated: Bool, steps: Int, calories: Int, distance: Double, last_upd: String) {
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.validated = validated
        self.steps = steps
        self.calories = calories
        self.distance = distance
        self.last_upd = last_upd
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty{
            return nil
        }
    }
    
}