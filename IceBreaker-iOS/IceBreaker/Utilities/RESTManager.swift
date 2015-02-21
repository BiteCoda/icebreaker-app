//
//  RESTManager.swift
//  IceBreaker
//
//  Created by Jacob Chen on 2/21/15.
//  Copyright (c) 2015 floridapoly.IceMakers. All rights reserved.
//

import UIKit

private let BASE_URL:String = "localhost:"

class RESTManager {
    
    class func register(deviceToken: String) {
        
        let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        
        var parameters: [String: String] = ["userId":"(major:\(Beacon.sharedBeacon.majorID), minor:\(Beacon.sharedBeacon.minorID))"]
        
        manager.POST(
            BASE_URL + "/subscribe",
            parameters: parameters,
            success:
            {
                (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                
                println(responseObj)
                
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                
                println(error)
                
            }
        
    }
}