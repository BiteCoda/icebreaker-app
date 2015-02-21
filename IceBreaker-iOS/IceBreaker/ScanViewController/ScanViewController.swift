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
    
    let beaconManager: BeaconManager = BeaconManager.sharedBeaconManager
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Add notification listener
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "foundBeacon:", name: NOTIF_BEACON_FOUND, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: Notification Center methods
    
    func foundBeacon(notification: NSNotification) {
        
        var luckyBeacon: ESTBeacon = notification.userInfo![NOTIF_BEACON_KEY] as ESTBeacon
        
        println("Received Notification beacon major id = \(luckyBeacon.major), minor = \(luckyBeacon.minor)")
        
    }
    
    @IBAction func didTouchUpInsideSearchButton(sender: AnyObject) {
        
        // Begin searching
    
        beaconManager.listenToRegion(majID: nil, minID: nil)
        
    }
    
    
}