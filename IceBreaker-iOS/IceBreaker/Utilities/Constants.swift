//
//  Constants.swift
//  IceBreaker
//
//  Created by Jacob Chen on 2/21/15.
//  Copyright (c) 2015 floridapoly.IceMakers. All rights reserved.
//

import Foundation

// MARK: NSNotifications
public let NOTIF_NONE_FOUND = "NOTIF_NO_BEACONS_FOUND"
public let NOTIF_ALL_BEACONS_FOUND = "NOTIF_ALL_BEACONS_FOUND"
public let NOTIF_BEACON_FOUND = "NOTIF_BEACON_FOUND"
public let NOTIF_ALL_BEACONS_KEY = "NOTIF_ALL_BEACONS_KEY"
public let NOTIF_BEACON_KEY = "NOTIF_BEACON_KEY"
public let NOTIF_BEACON_PAIRED = "NOTIF_BEACON_PAIRED"
public let NOTIF_CONTENT_KEY = "NOTIF_CONTENT_KEY"
public let NOTIF_REQUEST_FAILED = "NOTIF_REQUEST_FAILED"
public let NOTIF_ANSWER_RECEIVED = "NOTIF_ANSWER_RECEIVED"
public let NOTIF_ERROR_PAIR_EXISTS_SOURCE = "NOTIF_ERROR_PAIR_EXISTS_SOURCE"
public let NOTIF_ERROR_PAIR_EXISTS_TARGET = "NOTIF_ERROR_PAIR_EXISTS_TARGET"
public let NOTIF_ERROR_TARGET_NOT_SUBSCRIBED = "NOTIF_ERROR_TARGET_NOT_SUBSCRIBED"
public let NOTIF_ERROR_INVALID_REQUEST = "NOTIF_ERROR_INVALID_REQUEST"

// MARK: Http Requests
public let API_SUCCESS = "success"
public let API_OBJECT = "object"
public let API_ERRORS = "errors"
public let API_QUESTION = "quote"
public let API_AUTHOR = "author"
public let API_CATEGORY = "category"

// MARK: Apple Push Notifications
public let APS_KEY = "aps"
public let APS_ALERT = "alert"

// MARK: Error codes
public let ERROR_KEY_LOCALIZED = "NSLocalizedDescription"
public let ERROR_PAIR_EXISTS_SOURCE = "ERROR_PAIR_EXISTS_SOURCE"
public let ERROR_PAIR_EXISTS_TARGET = "ERROR_PAIR_EXISTS_TARGET"
public let ERROR_TARGET_NOT_SUBSCRIBED = "ERROR_TARGET_NOT_SUBSCRIBED"
public let ERROR_INVALID_REQUEST = "ERROR_INVALID_REQUEST"
public let ERROR_KEY = "ERROR"

public let ANSWER_KEY = "ANSWER"

// MARK: Storyboard IDs
public let AUTHENTICATION_CONTROLLER = "AuthenticationViewController"
