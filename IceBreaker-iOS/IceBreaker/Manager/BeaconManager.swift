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

enum beaconManagerMode {
    case discoveryAllMode
    case discoveryAnyMode
}

class BeaconManager : NSObject, ESTBeaconManagerDelegate, CBPeripheralManagerDelegate {
    
    let manager : ESTBeaconManager = ESTBeaconManager()
    var beaconRegion : ESTBeaconRegion?
    var majorID: NSNumber?
    var minorID: NSNumber?
    var myMode: beaconManagerMode?
    var myBTManager = CBPeripheralManager?()
    
    class var sharedBeaconManager : BeaconManager {
        
        return _SingletonSharedBeaconManager
        
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        switch peripheral.state {
        case CBPeripheralManagerState.PoweredOff:
            println("Bluetooth Powered off")
            
        case CBPeripheralManagerState.Unsupported:
            println("Unsupported")
            
        case CBPeripheralManagerState.Unauthorized:
            println("Unauthorized")
            
        case CBPeripheralManagerState.PoweredOn:
            println("Powered On")
            
        default:
            println("Default case")
            
        }
        
        
    }
    
    private override init() {
        super.init()
        self.myMode = beaconManagerMode.discoveryAnyMode
        manager.delegate = self
        myBTManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func listenToRegion(
        regionID: NSUUID = DEFAULT_UUID!,
        regionName: String = "Default Region",
        mode: beaconManagerMode,
        majID: NSNumber?,
        minID: NSNumber?
        )-> Bool
    {
            
        if myBTManager!.state == CBPeripheralManagerState.PoweredOn {
            majorID = majID
            minorID = minID
            
            beaconRegion = ESTBeaconRegion(
                proximityUUID: regionID,
                identifier: regionName
            )
            
            /*if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            manager.requestWhenInUseAuthorization()
            }*/
            
            self.myMode = mode
            manager.startMonitoringForRegion(beaconRegion)
            manager.startRangingBeaconsInRegion(beaconRegion)
            return true
        } else {
            
            return false
            
        }
            
    }
    
    
    internal func beaconManager(manager: ESTBeaconManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: ESTBeaconRegion!) {
        
        if beacons.count > 0 {
            
            switch self.myMode! {
                case .discoveryAnyMode:
                    
                    findOneBeacon(manager, didRangeBeacons: beacons, inRegion: region)
                    
                case .discoveryAllMode:
                    
                    findAllBeacons(manager, didRangeBeacons: beacons, inRegion: region)
                
            }
            
            
            
        } else {
        
            NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_NONE_FOUND, object: nil, userInfo: nil)
            
        }
        
        self.stop()
        
    }
    
    private func findAllBeacons(
        manager: ESTBeaconManager!,
        didRangeBeacons beacons: [AnyObject]!,
        inRegion region: ESTBeaconRegion!
        )
    {
            
        println("found beacons")
        
        var beacons: [ESTBeacon] = beacons as [ESTBeacon]
        
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_ALL_BEACONS_FOUND, object: nil, userInfo: [NOTIF_ALL_BEACONS_KEY: beacons])
        
    }
    
    private func findOneBeacon(
        manager: ESTBeaconManager!,
        didRangeBeacons beacons: [AnyObject]!,
        inRegion region: ESTBeaconRegion!)
    {
        
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
            
        }
        
    }
    
    internal func beaconManager(manager: ESTBeaconManager!, rangingBeaconsDidFailForRegion region: ESTBeaconRegion!, withError error: NSError!) {
        println("error \(error)")
    }
    
    private func stop() {
        
        // Stop listening
        manager.stopRangingBeaconsInRegion(beaconRegion)
        
    }
    
}
