//
//  helpers.swift
//  Coffee
//
//  Created by Joss Manger on 23/12/2015.
 
//

import Foundation

//Method to look for set key in NSUserDefaults

func keyAlreadyExist(test:String) -> Bool {
    if (NSUserDefaults.standardUserDefaults().objectForKey(test) != nil) {
        return true
    }else {
        return false
    }
}

//Get and return NSUserDefaults Value or nil
func getExistingValue(test:String) -> AnyObject? {
    if let gotValue = NSUserDefaults.standardUserDefaults().objectForKey(test){
        return gotValue
    }
    else {
        return false
    }
}