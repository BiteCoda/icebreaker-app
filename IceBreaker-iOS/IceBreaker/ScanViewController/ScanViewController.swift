//
//  ScanViewController.swift
//  IceBreaker
//
//  Created by Jacob Chen on 2/21/15.
//  Copyright (c) 2015 floridapoly.IceMakers. All rights reserved.
//

import UIKit

/*
    This View controller will be responsible for sniffing beacons in the region.
*/

class ScanViewController: UIViewController {
    
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var messageLabelView: UILabel!
    
    var beaconInQuestion: ESTBeacon?
    let beaconManager: BeaconManager = BeaconManager.sharedBeaconManager
    var answerNotification: Bool = false
    var searchMode: Bool = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Add notification listener
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "foundBeacon:", name: NOTIF_BEACON_FOUND, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beaconPaired:", name: NOTIF_BEACON_PAIRED, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "failedPairingSource:", name: NOTIF_ERROR_PAIR_EXISTS_SOURCE, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "failedPairingTarget:", name: NOTIF_ERROR_PAIR_EXISTS_TARGET, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "failedPairingInvalidRequest:", name: NOTIF_ERROR_INVALID_REQUEST, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "failedPairingTargetNotSubscribed:", name: NOTIF_ERROR_TARGET_NOT_SUBSCRIBED, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayAnswer:", name: NOTIF_ANSWER_RECEIVED, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: Notification Center methods
    
    func foundBeacon(notification: NSNotification) {
        
        beaconInQuestion = notification.userInfo![NOTIF_BEACON_KEY] as? ESTBeacon
        
        println("Received Notification beacon major id = \(beaconInQuestion!.major), minor = \(beaconInQuestion!.minor)")
        
        RESTManager.sharedRESTManager.request(beaconInQuestion!.major!, minorID: beaconInQuestion!.minor!)
        
        SVProgressHUD.show()
    }
    
    func beaconPaired(notification: NSNotification) {
        
        if !answerNotification {
        
            SVProgressHUD.dismiss()
            
            // Beacon paired, add to known beacons, display the question, change button text
            println ("Beacon has been paired ")
            
            /*
            Beacon.sharedBeacon.beaconsConnected.append(
                Beacon(majID: beaconInQuestion!.major!, minID: beaconInQuestion!.minor!)
            )
            */

            let content: String = notification.userInfo![NOTIF_CONTENT_KEY] as String
            
            println(content)
            
            self.messageLabelView.font = UIFont(name: "HelveticaNeue-Light", size: 35.0)
            self.messageLabelView.text = content
            
            self.searchButton.setTitle("Found!", forState: UIControlState.Normal)
            searchMode = false
        }
        
    }
    
    func failedPairingSource(notification: NSNotification) {
        
        if !answerNotification {
            SVProgressHUD.dismiss()
            println("Failed pairing source")
            RESTManager.sharedRESTManager.unpair()
            var alert: UIAlertController = UIAlertController(title: "Device Can't Pair", message: "Huh, weird...", preferredStyle: UIAlertControllerStyle.Alert)
            
            var dismissAction: UIAlertAction = UIAlertAction(title: "Okay, fine", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                
                alert.dismissViewControllerAnimated(true, completion: nil)
                
            }
            
            alert.addAction(dismissAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            println("Failed pairing target")
        }
        
    }
    
    func failedPairingTarget(notification: NSNotification) {
        
        if !answerNotification {
            SVProgressHUD.dismiss()
            var alert: UIAlertController = UIAlertController(title: "Device Can't Pair", message: "Target is taken already", preferredStyle: UIAlertControllerStyle.Alert)
            
            var dismissAction: UIAlertAction = UIAlertAction(title: "Okay, fine", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                
                alert.dismissViewControllerAnimated(true, completion: nil)
                
            }
            
            alert.addAction(dismissAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            println("Failed pairing target")
        }
        
    }
    
    func failedPairingInvalidRequest(notification: NSNotification) {
        
        if !answerNotification {
            SVProgressHUD.dismiss()
            println("Invalid Request")
        }
        
    }
    
    func failedPairingTargetNotSubscribed(notification: NSNotification) {
        
        if !answerNotification {
            SVProgressHUD.dismiss()
            Beacon.sharedBeacon.beaconsTried.push(Beacon(majID: beaconInQuestion!.major, minID: beaconInQuestion!.minor))
            println("Target not subscribed")
        }
        
    }
    
    func displayAnswer(notification: NSNotification) {
        
        var userInfo: NSDictionary = notification.userInfo! as NSDictionary
        
        var answer: String = userInfo[ANSWER_KEY] as String
        
        answerNotification = true
        
        SVProgressHUD.dismiss()
        
        self.messageLabelView.text = "Answer: \(answer)"
        self.searchButton.setTitle("Search", forState: UIControlState.Normal)
        
    }
    
    // MARK: Button Pressed methods
    
    @IBAction func didTouchUpInsideSearchButton(sender: AnyObject) {
        
        // check if this device has been registered
        
        if (searchMode) {
            
            // Search
            
            if RESTManager.sharedRESTManager.hasRegistered {
                
                // Begin searching
                //beaconManager.listenToRegion(majID: nil, minID: nil)
                
                RESTManager.sharedRESTManager.request(Beacon.sharedBeacon.majorID!, minorID: Beacon.sharedBeacon.minorID!)
                
                SVProgressHUD.show()
                
            } else {
                
                // Alert that the register hasn't happened yet
                var alert: UIAlertController = UIAlertController(title: "Device hasn't regiestered", message: "Please wait a little bit until you're registered", preferredStyle: UIAlertControllerStyle.Alert)
                
                var dismissAction: UIAlertAction = UIAlertAction(title: "Okay, fine", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                    
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    
                }
                
                alert.addAction(dismissAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            
        } else {
            
            // Back to search
            searchMode = true
            searchButton.setTitle("Search", forState: UIControlState.Normal)
            self.messageLabelView.text = ""
            answerNotification = false
            RESTManager.sharedRESTManager.unpair()
            
        }
        
    }
    
    
}