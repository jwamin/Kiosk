//
//  helpers.swift
//  Coffee
//
//  Created by Joss Manger on 23/12/2015.
 
//

import Foundation

//Method to look for set key in NSUserDefaults

func keyAlreadyExist(_ test:String) -> Bool {
    if (UserDefaults.standard.object(forKey: test) != nil) {
        return true
    }else {
        return false
    }
}

//Get and return NSUserDefaults Value or nil
func getExistingValue(_ test:String) -> AnyObject? {
    if let gotValue = UserDefaults.standard.object(forKey: test){
        return gotValue as AnyObject
    }
    else {
        return false as AnyObject
    }
}
