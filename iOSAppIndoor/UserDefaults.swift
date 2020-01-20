//
//  UserDefaults.swift
//  storeLastStatus
//
//  Created by mwnlMacbookPro on 2020/1/20.
//  Copyright © 2020 mwnlMacbookPro. All rights reserved.
//

import Foundation
extension UserDefaults {
    //first launch
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunched = "hasBeenLaunched"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunched)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunched)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
