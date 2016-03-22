//
//  HealthKitHelper.swift
//  myResearchKit
//
//  Created by Shashank Kothapalli on 8/5/15.
//  Copyright (c) 2015 Amgen. All rights reserved.
//

import Foundation
import HealthKit
import Charts

var dates = [String]()
var stepsOver = [Double]()
var heartRate = [Double]()
var dateOfMax = [String]()
var sleepAnalysis = [String]()
var calories = [String]()
var stairClimbRate = [Double]()

class HealthKit
{
    
    let HealthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success: Bool, error:NSError!)->Void)!){
        
        //types of info to write
        let infoToRead:Set = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!
        ]
        let infoToWrite:Set = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!
        ]
        //check if store is not available
        if !HKHealthStore.isHealthDataAvailable(){
            let error = NSError(domain: "Amgen HealthKit",
                code: 1111,
                userInfo: [NSLocalizedDescriptionKey: "HK Store Not Available"]
            )
            if(completion != nil){
                completion(success:false, error: error)
            }
            return
        }
        
        HealthKitStore.requestAuthorizationToShareTypes(infoToWrite, readTypes:infoToRead){(success,error) -> Void in
            if(completion != nil){
                completion(success:success, error: error)
            }
        }
    }
    
    func saveBMISample(bmi:Double, date:NSDate ) {
        
        // 1. Create a BMI Sample
        let bmiType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
        let bmiQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: bmi)
        let bmiSample = HKQuantitySample(type: bmiType!, quantity: bmiQuantity, startDate: date, endDate: date)
        
        // 2. Save the sample in the store
        HealthKitStore.saveObject(bmiSample, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                print("Error saving BMI sample: \(error!.localizedDescription)")
            } else {
                print("BMI sample saved successfully!")
            }
        })
    }

    
    func dataTypesToWrite() -> NSSet {
        let steps = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        return NSSet(object: steps!)
    }
    
    
    func distanceSampleWithDistance(distance: Double) -> HKQuantitySample {
        let quantityType: HKQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let distanceUnit: HKUnit = HKUnit(fromLengthFormatterUnit: .Meter)
        let quantity: HKQuantity = HKQuantity(unit: distanceUnit, doubleValue: distance)
        return HKQuantitySample(type: quantityType, quantity: quantity, startDate: NSDate(), endDate: NSDate())
    }
    
    
    func saveDistanceValueToHealthKit(distance: Double, withCompletion completion: ((Bool, NSError!) -> Void)!) {
        let distanceSample = distanceSampleWithDistance(145.03)
        
        HealthKitStore.saveObject(distanceSample, withCompletion: { (success, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if error == nil
                {
                    // saved successfully
                    completion(success, error)
                }
                else
                {
                    print("Error occured while saving to Health Kit: \(error!.localizedDescription)")
                    completion(success, error)
                }
            })
        })
    }
    
    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!)
    {
        
        // 1. Build the Predicate
        let past = NSDate.distantPast() as! NSDate
        let now   = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
        
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 1
        
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                
                if let queryError = error {
                    completion(nil,error)
                    return;
                }
                
                // Get the first sample
                let mostRecentSample = results!.first as? HKQuantitySample
                
                // Execute the completion closure
                if completion != nil {
                    completion(mostRecentSample,nil)
                }
        }
        // 5. Execute the Query
        self.HealthKitStore.executeQuery(sampleQuery)
    }

   
    
    
    
    func readSteps() -> Void
    {
        print("Entered read profile")
        let calendar = NSCalendar.currentCalendar()
        
        let interval = NSDateComponents()
        interval.day = 7
        
        // Set the anchor date to Monday at 3:00 a.m.
        let anchorComponents =
        calendar.components([.Day, .Month, .Year, .Weekday], fromDate: NSDate())
        
        let offset = (7 + anchorComponents.weekday - 2) % 7
        anchorComponents.day -= offset
        anchorComponents.hour = 3
        
        let anchorDate = calendar.dateFromComponents(anchorComponents)
        
        let quantityType =
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
            quantitySamplePredicate: nil,
            options: .CumulativeSum,
            anchorDate: anchorDate!,
            intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            if error != nil {
                // Perform proper error handling here
                print("*** An error occurred while calculating the statistics: \(error!.localizedDescription) ***")
                abort()
            }
            
            let endDate = NSDate()
            let startDate =
            calendar.dateByAddingUnit(.NSMonthCalendarUnit,
                value: -3, toDate: endDate, options: [])
            
            // Plot the weekly step counts over the past 3 months
            results!.enumerateStatisticsFromDate(startDate!, toDate: endDate) {
                statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let stepsValue = quantity.doubleValueForUnit(HKUnit.countUnit())
                    
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MMM"
                    
                    var month = dateFormatter.stringFromDate(date)
                    dates.append(month)
                    stepsOver.append(stepsValue)
                    
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.HealthKitStore.executeQuery(query)
        })
    }
    
    func readHeartRate() -> Void
    {
        print("inside heart rate")
        let heartRateValue = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        let calendar = NSCalendar.currentCalendar()
        
        let endDate = calendar.dateByAddingUnit(.WeekOfYear, value: 0, toDate: NSDate(), options:[])
        let startDate = calendar.dateByAddingUnit(.WeekOfYear, value: -2, toDate: NSDate(), options: [])
        
        let samplePredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: HKQueryOptions.StrictStartDate)
        
        let sorter = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)

        let query = HKSampleQuery(sampleType:heartRateValue!, predicate:samplePredicate, limit:600, sortDescriptors:[sorter], resultsHandler:{(query, results, error) in
        
            for sample in results! {
                let heartRateUnit: HKUnit = HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit())
                let quantity = (sample as! HKQuantitySample).quantity
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMM dd"
                
                var day = dateFormatter.stringFromDate(sample.startDate)
                dateOfMax.append(day)
                heartRate.append(quantity.doubleValueForUnit(heartRateUnit))
            }
            
            var error: NSError? = nil
        })
        dispatch_async(dispatch_get_main_queue(), {
            self.HealthKitStore.executeQuery(query)
        })
    }
    
    
    
    func readStairsClimbRate() -> Void
    {
        print("Entered read profile")
        let calendar = NSCalendar.currentCalendar()
        
        let interval = NSDateComponents()
        interval.day = 7
        
        // Set the anchor date to Monday at 3:00 a.m.
        let anchorComponents =
        calendar.components([.Day, .Month, .Year, .Weekday], fromDate: NSDate())
        
        let offset = (7 + anchorComponents.weekday - 2) % 7
        anchorComponents.day -= offset
        anchorComponents.hour = 3
        
        let anchorDate = calendar.dateFromComponents(anchorComponents)
        
        let quantityType =
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
            quantitySamplePredicate: nil,
            options: .CumulativeSum,
            anchorDate: anchorDate!,
            intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            if error != nil {
                // Perform proper error handling here
                print("*** An error occurred while calculating the statistics: \(error!.localizedDescription) ***")
                abort()
            }
            
            let endDate = NSDate()
            let startDate =
            calendar.dateByAddingUnit(.NSMonthCalendarUnit,
                value: -3, toDate: endDate, options: [])
            
            // Plot the weekly step counts over the past 3 months
            results!.enumerateStatisticsFromDate(startDate!, toDate: endDate) {
                statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let stepsValue = quantity.doubleValueForUnit(HKUnit.countUnit())
                    
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MMM"
                    
                    var month = dateFormatter.stringFromDate(date)
                    dates.append(month)
                    stairClimbRate.append(stepsValue)
                    
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.HealthKitStore.executeQuery(query)
        })
        
        
    }
    
}
