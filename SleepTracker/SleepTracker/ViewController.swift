//
//  ViewController.swift
//  SleepTracker
//
//  Copyright © 2019 Luis Paz. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var displayTimeLabel: UILabel!
    
    var startTime = TimeInterval()
    var timer:Timer = Timer()
    let healthStore = HKHealthStore()
    var endTime: NSDate!
    var alarmTime: NSDate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Specifiying the types to read (same as the one to write) from HealthStore
        let typestoRead = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ])
        
        // Specifiying the types to write (same as the one to read) from HealthStore
        let typestoShare = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ])
        
        // Needing authorization to continue
        self.healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
            if success == false {
                NSLog("Display not allowed.")
                
                let alert = UIAlertController(title: "There was no authorization allowed.", message: "No access was granted.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func start(_ sender: Any) {
        alarmTime = NSDate()
        if (!timer.isValid) {
            let aSelector : Selector = #selector(ViewController.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate
        }
    }
    
    @IBAction func stop(_ sender: Any) {
        endTime = NSDate()
        self.saveSleepAnalysis()
        self.retrieveSleepAnalysis()
        timer.invalidate()
        
        let timeRecorded = displayTimeLabel.text
        
        let alert = UIAlertController(title: "Sleep Analysis", message: "Time spent in bed and asleep has been added to the Health application with a recorded time of \(timeRecorded ?? "NA.")", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in self.setAlertUpdate()}))
        self.present(alert, animated: true)
        
    }
    
    func setAlertUpdate() {
        UIApplication.shared.open(URL(string: "x-apple-health://")!)
    }
    
    @objc func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        // Find the difference between current time and start time.
        var elapsedTime: TimeInterval = currentTime - startTime
        
        // print(elapsedTime)
        // print(Int(elapsedTime))
        
        // Minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        // Seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        // Milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //Current minutes, seconds and milliseconds as assign it to the UILabel
        displayTimeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    func saveSleepAnalysis() {
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Create a new object we want to push in Health app
            let object = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: self.alarmTime as Date, end: self.endTime as Date)
            
            // Pushing the object to HealthStore
            healthStore.save(object, withCompletion: { (success, error) -> Void in
                if error != nil {
                    print("Error in pushing 'inBed' object to HealthStore.")
                    return
                }
                if success {
                    print("My health and sleep data was saved in Healthkit.")
                } else {
                    print("Further error in pushing 'inBed' object to HealthStore.")
                }
                
            })
            
            
            let object2 = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.asleep.rawValue, start: self.alarmTime as Date, end: self.endTime as Date)
            
            
            healthStore.save(object2, withCompletion: { (success, error) -> Void in
                if error != nil {
                    print("Error in pushing 'asleep' object to HealthStore.")
                    return
                }
                
                if success {
                    print("My health and sleep data was saved in Healthkit.")
                } else {
                    print("Further error in pushing 'asleep' object to HealthStore.")
                }
            })
            
            
        }
        
    }
    
    func retrieveSleepAnalysis() {
        // startDate and endDate are NSDate objects
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            // Predicate to filter the data... startDate and endDate are NSDate objects corresponding to the time range that you want to retrieve
            
            //let predicate = HKQuery.predicateForSamplesWithStartDate(startDate,endDate: endDate ,options: .None)
            // Get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // the block completion to execute
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    print("My health and sleep data could not be retrieved in Healthkit.")
                    return
                }
                
                if let result = tmpResult {
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                        }
                    }
                }
            }
            
            
            healthStore.execute(query)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

