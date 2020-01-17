//
//  valueForAPIKey.swift
//  hideAPIkeys
//
//  Created by mwnlMacbookPro on 2020/1/16.
//  Copyright © 2020 mwnlMacbookPro. All rights reserved.
//

import Foundation

func valueForAPIKey(named keyname:String) -> String {
    // Credit to the original source for this technique at
    let filePath = Bundle.main.path(forResource: "keys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    let value = plist?.object(forKey: keyname) as! String
    return value
}
