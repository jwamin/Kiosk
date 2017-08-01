//
//  model.swift
//  Coffee
//
//  Created by Joss Manger on 23/12/2015.
 
//

import Foundation

//MARK: - Preprocessor variables

#if DEBUG
let appURL = "" //FIREBASE DEBUG URL
let debug = true;
#else
let debug = false;
let appURL = "" //FIREBASE LIVE URL
#endif

//MARK: - App Global 'let' constants

let kUsernameKey = "uname"

let notificationReceived = "notificationReceived"

let resetSettingsKey = "reset_on_next_run";

let halfShotEnabledKey = "half_shot_enabled";

let favourite = "favourite"

let orderIDk = "orderID"

var drinks = [];

var syrups = [];

let styleArr = [
"Regular","Skinny"
]
