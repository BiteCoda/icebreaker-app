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

private let USER_ID_KEY = "userId"
private let DEVICE_TOKEN_KEY = "deviceToken"
private let DEVICE_TYPE_KEY = "deviceType"
private let PASSWORD_KEY = "password"
private let TARGET_USER_ID_KEY = "targetUserId"

class RESTManager {
    
    let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
    var hasRegistered: Bool = false
    var deviceToken: String?
    
    class var sharedRESTManager : RESTManager {
        
        return _SingletonSharedRESTManager
        
    }
    
    init() {
        
    }
    
    func register(deviceToken: String, password: String, completionClosure:(success: Bool) ->()) {
        
        println("Subscribing")
        
        let majorID: NSNumber = Beacon.sharedBeacon.majorID!
        let minorID: NSNumber = Beacon.sharedBeacon.minorID!
        
        var parameters: [String: String] = [
            USER_ID_KEY:"(major:\(majorID), minor:\(minorID))",
            DEVICE_TOKEN_KEY:deviceToken,
            DEVICE_TYPE_KEY:"ios",
            PASSWORD_KEY: password
        ]
        
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
                        completionClosure(success: true)
                    }
                    
                } else {
                    
                    completionClosure(success: false)
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
            USER_ID_KEY:"(major:\(majorID), minor:\(minorID))",
            TARGET_USER_ID_KEY:"(major:\(targetMajorID), minor:\(targetMinorID))"
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
        
        var parameters: [String: String] = [
            USER_ID_KEY:"(major:\(majorID), minor:\(minorID))"
        ]
        
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