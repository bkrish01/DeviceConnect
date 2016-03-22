//
//  BMIViewController.swift
//  DevCon
//
//  Created by Krishnapillai, Bala on 3/7/16.
//  Copyright © 2016 AMGEN. All rights reserved.
//

import UIKit
import ResearchKit
import MessageUI


class BMIViewController: UIViewController {
    
    let healthManager:HealthKit = HealthKit()
    let kUnknownString   = "Unknown"

    
    @IBOutlet weak var heightLabel: UITextField!
    @IBOutlet weak var weightLabel: UITextField!
    @IBOutlet weak var BMlLabel: UILabel!
  
    
    
    var bmi:Double?
    var height, weight:HKQuantitySample?
    


    override func viewDidLoad() {
        super.viewDidLoad()
      

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - utility methods
    func calculateBMIWithWeightInKilograms(weightInKilograms:Double, heightInMeters:Double) -> Double?
    {
        if heightInMeters == 0 {
            return nil;
        }
        return (weightInKilograms/(heightInMeters*heightInMeters));
    }
    
    
    
    @IBAction func Done(sender: AnyObject) {
        updateHeight()
        updateWeight()
        saveBMI()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateHeight()
    {
        // 1. Construct an HKSampleType for Height
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        
        // 2. Call the method to read the most recent Height sample
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentHeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading height from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var heightLocalizedString = self.kUnknownString;
            //var heightLocalizedString = "180"
            self.height = mostRecentHeight as? HKQuantitySample;
            // 3. Format the height to display it on the screen
            if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
                let heightFormatter = NSLengthFormatter()
                heightFormatter.forPersonHeightUse = true;
                heightLocalizedString = heightFormatter.stringFromMeters(meters);
                print ("Height: \(heightLocalizedString)")
            }
            
            
            // 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.heightLabel.text = heightLocalizedString
                self.updateBMI()
            });
        })
        
    }
    
    func updateWeight()
    {
        // 1. Construct an HKSampleType for weight
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        // 2. Call the method to read the most recent weight sample
        self.healthManager.readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var weightLocalizedString = self.kUnknownString;
            //var weightLocalizedString = "180";
            // 3. Format the weight to display it on the screen
            self.weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
                let weightFormatter = NSMassFormatter()
                weightFormatter.forPersonMassUse = true;
                weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
            }
            
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.weightLabel.text = weightLocalizedString
                self.updateBMI()
                
            });
        });
    }
    
    
    
    
    func updateBMI()
    {
        print("Weight inside update BMI =\(weight)")
        print("Height inside update BMI =\(height)")
        
        if weight != nil && height != nil {
            // 1. Get the weight and height values from the samples read from HealthKit
            let weightInKilograms = weight!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
            let heightInMeters = height!.quantity.doubleValueForUnit(HKUnit.meterUnit())
            // 2. Call the method to calculate the BMI
            bmi  = calculateBMIWithWeightInKilograms(weightInKilograms, heightInMeters: heightInMeters)
        }
        // 3. Show the calculated BMI
                var bmiString = kUnknownString
                if bmi != nil {
                    BMlLabel.text =  String(format: "%.02f", bmi!)
                }
        saveBMI()
        print("BMI =\(bmi)")
        
    }
    
    func saveBMI() {
        
        // Save BMI value with current BMI value
        if bmi != nil {
            healthManager.saveBMISample(bmi!, date: NSDate())
            print("BMI data saved on HealthKit Dashboard")
        }
        else {
            print("There is no BMI data to save")
        }
        
    }
    

    @IBAction func Cancel(sender: AnyObject) {
        undoManager
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

}
