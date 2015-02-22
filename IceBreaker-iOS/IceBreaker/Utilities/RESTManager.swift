//
//  RESTManager.swift
//  IceBreaker
//
//  Created by Jacob Chen on 2/21/15.
//  Copyright (c) 2015 floridapoly.IceMakers. All rights reserved.
//

import UIKit

private let BASE_URL:String = "http://icebreaker.duckdns.org"

private let _SingletonSharedRESTManager = RESTManager()

class RESTManager {
    
    let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
    var hasRegistered: Bool = false
    
    class var sharedRESTManager : RESTManager {
        
        return _SingletonSharedRESTManager
        
    }
    
    init() {
        
    }
    
    func register(deviceToken: String) {
        
        println("Subscribing")
        
        let majorID: NSNumber = Beacon.sharedBeacon.majorID!
        let minorID: NSNumber = Beacon.sharedBeacon.minorID!
        
        var parameters: [String: String] = ["userId":"(major:\(majorID), minor:\(minorID))", "deviceToken":deviceToken, "deviceType":"ios"]
        
        manager.POST(
            BASE_URL + "/subscribe",
            parameters: parameters,
            success:
            {
                (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                
                var result: NSDictionary = responseObj as NSDictionary
                
                var success: Bool = result.objectForKey(API_SUCCESS) as Bool
                
                if (success) {
                    
                    if !self.hasRegistered {
                        self.hasRegistered = true
                        println("Registered with server")
                    }
                    
                } else {
                    
                    
                }
                
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                
                println(error)
                
            }
    }
    
    func request(targetMajorID: NSNumber, targetMinorID: NSNumber) {
        
        let majorID: NSNumber = Beacon.sharedBeacon.majorID!
        let minorID: NSNumber = Beacon.sharedBeacon.minorID!
        
        var parameters: [String: String] = [
            "userId":"(major:\(majorID), minor:\(minorID))",
            "targetUserId":"(major:\(targetMajorID), minor:\(targetMinorID))"
        ]
        
        println("Messaging: \(parameters)")
        
        manager.POST(
            BASE_URL + "/message",
            parameters: parameters,
            success:
            {
                (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                
                var response: NSDictionary = responseObj as NSDictionary
                
                var success: Bool = response.objectForKey(API_SUCCESS) as Bool
                
                if (success) {
                    
                    var object: NSDictionary = response.objectForKey(API_OBJECT) as NSDictionary
                    var question: String = object.objectForKey(API_QUESTION) as String
                    var author: String = object.objectForKey(API_AUTHOR) as String
                    var category: String = object.objectForKey(API_CATEGORY) as String
                    var content = "Quote: \(question)\nAuthor: \(author)\nCategory: \(category)"
                    
                    var info: [String: String] = [NOTIF_CONTENT_KEY: content]
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        NOTIF_BEACON_PAIRED,
                        object: nil,
                        userInfo: info
                    )
                    
                    println(responseObj)
                    
                } else {
                    
                    var errors: [String] = response.objectForKey(API_ERRORS) as [String]
                    for error in errors {
                        switch error {
                        case ERROR_PAIR_EXISTS_SOURCE:
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_ERROR_PAIR_EXISTS_SOURCE, object: nil)
                            break;
                        case ERROR_PAIR_EXISTS_TARGET:
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_ERROR_PAIR_EXISTS_TARGET, object: nil)
                            break;
                        case ERROR_INVALID_REQUEST:
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_ERROR_INVALID_REQUEST, object: nil)
                            break;
                        case ERROR_TARGET_NOT_SUBSCRIBED:
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_ERROR_TARGET_NOT_SUBSCRIBED, object: nil)
                            break;
                        default:
                            break;
                        }
                        
                    }
                    
                }
                
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                
                println(error)
                
        }
    }
    
    func unpair() {
        
        println("Unpairing")
        
        let majorID: NSNumber = Beacon.sharedBeacon.majorID!
        let minorID: NSNumber = Beacon.sharedBeacon.minorID!
        
        var parameters: [String: String] = ["userId":"(major:\(majorID), minor:\(minorID))"]
        
        manager.POST(
            BASE_URL + "/unpair",
            parameters: parameters,
            success: {
                (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                
                println("Pairing Successful")
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                
                println(error)
            
        }
        
    }
    
}