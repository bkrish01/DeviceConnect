//
//  DashboardTableViewController.swift
//  
//
//  Created by Krishnapillai, Bala on 2/9/16.
//
//

import UIKit
import ResearchKit
import MessageUI

class DashboardTableViewController: UITableViewController {
 

    let healthManager:HealthKit = HealthKit()
    
    //MARK: Properties
    
    var UserId,ValidicId,UserToken,OrganizationId,AuthToken : String!
    var myResult: NSDictionary!
    var routineRecord :NSDictionary!
    var dashboards = [Dashboard]()
    var tabledata = [TableData]()
    var stepsdic : NSDictionary!

    var bmi:Double?
    var height, weight:HKQuantitySample?



    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let VUser = NSUserDefaults.standardUserDefaults().valueForKey("_id")
        {

            var newDate  =  NSDate()
            let yesterday = newDate.dateByAddingTimeInterval(-72 * 60 * 60)
            let newdateFormatter = NSDateFormatter()
            newdateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            print ("Yesterday print date obj = "+newdateFormatter.stringFromDate(yesterday))
            
//          GetUserRoutineActivity("https://api.validic.com/v1/organizations/5412de4e965fe22a1c000149/users/56b918002604cea53e0000b3/routine.json?access_token=fd63d2852e1c4e099d17fea2095fc154d0331e87f31f44325eeffdc4662a1d9a&start_date=\(newdateFormatter.stringFromDate(yesterday))")
            GetUserRoutineActivity("https://api.validic.com/v1/organizations/5412de4e965fe22a1c000149/users/\(VUser)/routine.json?access_token=fd63d2852e1c4e099d17fea2095fc154d0331e87f31f44325eeffdc4662a1d9a&start_date=\(newdateFormatter.stringFromDate(yesterday))")
            
//            GetUserRoutineActivity("https://api.validic.com/v1/organizations/5412de4e965fe22a1c000149/users/\(VUser)/routine.json?access_token=fd63d2852e1c4e099d17fea2095fc154d0331e87f31f44325eeffdc4662a1d9a&start_date=\(converted)T00:00:00+00:00")
//
        }
       
          // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        //updateHeight()
        //updateWeight()
        //saveBMI()
    }
    
    // MARK: - utility methods
    func calculateBMIWithWeightInKilograms(weightInKilograms:Double, heightInMeters:Double) -> Double?
    {
        if heightInMeters == 0 {
            return nil;
        }
        return (weightInKilograms/(heightInMeters*heightInMeters));
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
            
            //var heightLocalizedString = self.kUnknownString;
            var heightLocalizedString = "180"
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
                //self.heightLabel.text = heightLocalizedString
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
            
            //var weightLocalizedString = self.kUnknownString;
            var weightLocalizedString = "180";
            // 3. Format the weight to display it on the screen
            self.weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
                let weightFormatter = NSMassFormatter()
                weightFormatter.forPersonMassUse = true;
                weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
            }
            
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //self.weightLabel.text = weightLocalizedString
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
//        var bmiString = kUnknownString
//        if bmi != nil {
//            bmiLabel.text =  String(format: "%.02f", bmi!)
//        }
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

    
    
    

    func handleRefresh(refreshControl: UIRefreshControl)
    {
        self.tableView.reloadData()
        refreshControl.endRefreshing()

    }
    
    func displayMyAlertMessage(userMessage :String)
    {
        var myAlert = UIAlertController(title: "Login Error",  message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil);
    }

    func GetUserRoutineActivity(sURL: NSString)
    {
       
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
                    print("Validic Response String \(String(data: data!, encoding: NSUTF8StringEncoding))")
                    
                    if json.count > 2
                    {
                     let routineObject = json.objectForKey("routine") as! NSMutableArray
                     let photo1 =  UIImage(named:"fitbit-icon")!
                     for var i=0; i<routineObject.count; i++ {
                     let thisObj = routineObject[i] as! NSDictionary
                     let dashboardObj = Dashboard(name:thisObj.valueForKey("source_name") as! String, photo: photo1, validated: thisObj.valueForKey("validated") as! Bool, steps: thisObj.valueForKey("steps") as! Int, calories: thisObj.valueForKey("calories_burned") as! Int , distance: thisObj.valueForKey("distance") as! Double, last_upd: thisObj.valueForKey("last_updated") as! String)!
                        self.dashboards.append(dashboardObj)
                    }
                    self.tableView.reloadData()
                    }else{
                        self.displayMyAlertMessage(" Please allow few minutes for the data to appear in this screen.")
                    }
                }
                catch let error as NSError {
                    print("Validic json response error: \(error.localizedDescription)")
                }

            }
            
        }

        print("dash count\(dashboards.count)")
        task.resume()
    }
    
    
    @IBAction func ShowProfile(sender: AnyObject) {
       
     performSegueWithIdentifier("ProfileUserSegue", sender: self)
    }

   
    @IBAction func Done(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dashboards.count

    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MyDeviceTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MyDeviceTableViewCell
        let Dashboard = dashboards[indexPath.row]
        print ("Dashboard Data\(Dashboard.name)")
        
        let strDate = String(Dashboard.last_upd) // "2015-10-06T15:42:34Z"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        print ( dateFormatter.dateFromString( strDate ) )
        
        var newDate  =  dateFormatter.dateFromString( strDate )
        let newdateFormatter = NSDateFormatter()
        newdateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        print ("new date obj ="+newdateFormatter.stringFromDate(newDate!))
        
        
        let date = dateFormatter.dateFromString( strDate )
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date!)
        
        print (components.year)
        print (components.month)
        print (components.day)
        
        var disp = "\(String(components.month)) | \(String(components.day))"
        //cell.CalDate.text = String(components.day)
        cell.CalDate.text = String(disp)

        let photo1 =  UIImage(named:"fitbit-icon")!
        let photo2 =  UIImage(named:"steps")!
        let photo3 =  UIImage(named:"map-marker-icon")!
        let photo4 =  UIImage(named:"calories")!
        let photo5 =  UIImage(named:"sleep")!
        let photo6 =  UIImage(named:"water")!
        
        //cell.nameLabel.text = Dashboard.name
        cell.photoImageView.image = Dashboard.photo
//        if Dashboard.validated {
//        cell.StatusLabel.text = "Connected"
//        }else
//        {
//        cell.StatusLabel.text = "Disconnected"
//        }
        
        let nformat = NSNumberFormatter()
        nformat.numberStyle = NSNumberFormatterStyle.DecimalStyle
        cell.steps.text = String(nformat.stringFromNumber(Dashboard.steps)!)
        cell.calories.text = String(nformat.stringFromNumber(Dashboard.calories)!)
 
        let y = Double(round(100 * (Dashboard.distance/1000))/100)
        cell.distance.text = String(y)
        cell.last_upd.text = String(Dashboard.last_upd)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        var output = formatter.dateFromString(String(Dashboard.last_upd))
        print("Output\(output)")
        
        
        
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        //dateStringFormatter.locale = NSLocale(localeIdentifier: "fr_CH_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
}

  