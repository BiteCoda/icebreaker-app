//
//  BeaconManager.swift
//  IceBreaker
//
//  Created by Jacob Chen on 2/21/15.
//  Copyright (c) 2015 floridapoly.IceMakers. All rights reserved.
//

//
//  EstimoteBeaconManager.swift
//  Estimote-Range-Data-Dumper
//
//  Created by Jacob Chen on 2/19/15.
//  Copyright (c) 2015 Looped LLC. All rights reserved.
//

import Foundation

/*
Default UUID: B9407F30-F5F8-466E-AFF9-25556B57FE6D
(major:46555, minor:50000),
(major:31782, minor:36689),
(major:19714, minor:49179)
*/

private let _SingletonSharedBeaconManager = BeaconManager()
private let DEFAULT_UUID = NSUUID(UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D")

class BeaconManager : NSObject, ESTBeaconManagerDelegate {
    
    let manager : ESTBeaconManager = ESTBeaconManager()
    var beaconRegion : ESTBeaconRegion?
    var majorID: NSNumber?
    var minorID: NSNumber?
    
    class var sharedBeaconManager : BeaconManager {
        
        return _SingletonSharedBeaconManager
        
    }
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func listenToRegion(
        regionID: NSUUID = DEFAULT_UUID!,
        regionName: String = "Default Region",
        majID: NSNumber?,
        minID: NSNumber?
        ) {
            
            majorID = majID
            minorID = minID
            
            beaconRegion = ESTBeaconRegion(
                proximityUUID: regionID,
                identifier: regionName
            )
            
            /*if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
                manager.requestWhenInUseAuthorization()
            }*/
            
            manager.startMonitoringForRegion(beaconRegion)
            manager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    
    func beaconManager(manager: ESTBeaconManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: ESTBeaconRegion!) {
        
        if beacons.count > 0 {
            
            println("found beacons")
            
            var filteredBeacons: [ESTBeacon] = beacons as [ESTBeacon]
            
            // Find beacon that is not your own
            filteredBeacons = filteredBeacons.filter{
                $0.major != Beacon.sharedBeacon.majorID! &&
                $0.minor != Beacon.sharedBeacon.minorID!
            }
            
            println("after 1st filter count is now \(filteredBeacons.count)")
            
            // Filter for beacons that were connected already
            for beacon in Beacon.sharedBeacon.beaconsConnected {
                filteredBeacons = filteredBeacons.filter {
                    $0.major != beacon.majorID! &&
                    $0.minor != beacon.minorID!
                }
            }
            
            println("after 2nd filter count is now \(filteredBeacons.count)")
            
            // Filter for beacons in tried connection FIFO
            var queue: [Beacon] = Beacon.sharedBeacon.beaconsTried.myQueue as [Beacon]
            
            println(queue)
            for beacon in queue {
                
                println("beacon maj: \(beacon.majorID) min: \(beacon.minorID)")
                
                filteredBeacons = filteredBeacons.filter {
                    $0.major != beacon.majorID! &&
                        $0.minor != beacon.minorID!
                }
            }
            println("after 3rd filter count is now \(filteredBeacons.count)")
            
            // Get the first beacon you see.
            if filteredBeacons.count > 0 {
                let luckyBeacon: ESTBeacon = filteredBeacons.first!
                
                println("Found beacon with major ID: \(luckyBeacon.major) and minor ID: \(luckyBeacon.minor)")
                
                NSNotificationCenter.defaultCenter().postNotificationName(
                    NOTIF_BEACON_FOUND,
                    object: nil,
                    userInfo: [NOTIF_BEACON_KEY:luckyBeacon]
                )
                
                self.stop()
            }
        }
        
    }
    
    func beaconManager(manager: ESTBeaconManager!, rangingBeaconsDidFailForRegion region: ESTBeaconRegion!, withError error: NSError!) {
        println(error)
    }
    
    func stop() {
        
        // Stop listening
        manager.stopRangingBeaconsInRegion(beaconRegion)
        
    }
    
}
