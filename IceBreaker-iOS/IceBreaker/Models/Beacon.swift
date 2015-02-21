//
//  Beacon.swift
//  IceBreaker
//
//  Created by Jacob Chen on 2/21/15.
//  Copyright (c) 2015 floridapoly.IceMakers. All rights reserved.
//

import Foundation

// For now assume that you have an associated Beacon ID
private let _SingletonSharedBeacon = Beacon(majID: 46555, minID: 50000)

class Beacon {
    
    var majorID: NSNumber?
    var minorID: NSNumber?
    
    class var sharedBeacon : Beacon {
        
        return _SingletonSharedBeacon
        
    }
    
    init() {
        
    }
    
    init (majID: NSNumber, minID: NSNumber) {
        
        self.majorID = majID
        self.minorID = minID
    }
    
}