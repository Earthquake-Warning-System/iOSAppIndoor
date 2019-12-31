//
//  ViewController.swift
//  3Axis_Geosensor
//
//  Created by Macbook on 8/30/19.
//  Copyright © 2019 com.macbook. All rights reserved.
//

import UIKit
import CoreMotion

var kpAliveTime: Date?
var kpAliveCount = 0
var meanAccl = 0.0
var logAcclTime: Date?
var logAcclCount = 0
var logAccl = Array(repeating: 0.0, count: 500)

//present lastkpAlive time and mean of Accl.
class logController: UIViewController {
    
    @IBOutlet weak var log: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if kpAliveTime != nil{
            let presentKpAliveTime = date2String(kpAliveTime!)
            print("kpAliveTimes is \(kpAliveCount) at \(presentKpAliveTime)" )
            log.text = "kpAliveTimes is \(kpAliveCount) at \(presentKpAliveTime) GMT＋08:00\n"
        }else{
            print("kpAliveTimes cannot be sent.")
            log.text = "kpAliveTimes cannot be sent.\n"
        }
        
        print("Accl = \(meanAccl)")
        log.isEditable = false
        log.textContainer.maximumNumberOfLines = 100
        log.isScrollEnabled = true
        log.backgroundColor = UIColor.black
        log.textColor = UIColor.white
        log.text += "Accl = \(logAccl)"
        
    }
    func date2String(_ date:Date, dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_Hant_TW")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date
    }
}