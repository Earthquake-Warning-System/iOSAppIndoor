//
//  logController.swift
//  3Axis_Geosensor
//
//  Created by Macbook on 8/30/19.
//  Copyright © 2019 com.macbook. All rights reserved.
//

import UIKit
import CoreMotion

var kpAliveTime: Date?
var eqEventTime: Date?
var kpAliveCount = 0
var eqEventCount = 0
var totalAccl = 0.0
var logAcclTime: Date?
var logAccl = 0.0

//present lastkpAlive time and mean of Accl.
class logController: UIViewController {
    
    @IBOutlet weak var log: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if kpAliveTime != nil{
            let presentKpAliveTime = date2String(kpAliveTime!)
            print("kpAliveTimes is \(kpAliveCount) at \(presentKpAliveTime)" )
            log.text = "kpAliveTimes is \(kpAliveCount) at \(presentKpAliveTime) GMT＋08:00.\n"
        }else{
            print("kpAliveTimes cannot be sent.")
            log.text = "kpAliveTimes cannot be sent.\n"
        }
        
        if eqEventTime != nil{
            let presentEqEventTime = date2String(eqEventTime!)
            print("EqEventTimes is \(eqEventCount) at \(presentEqEventTime)" )
            log.text += "EqEventTimes is \(eqEventCount) at \(presentEqEventTime) GMT＋08:00.\n"
        }else{
            print("EqEvent is not detected.")
            log.text += "EqEvent is not detected.\n"
        }
        print(presentAccl.count)
        print("Accl = \(totalAccl)")
        
        log.isEditable = false
        log.textContainer.maximumNumberOfLines = 100
        log.isScrollEnabled = true
        log.backgroundColor = UIColor.black
        log.textColor = UIColor.white
        //log.text += "Accl = \(logAccl)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(isPresentAccl(notification:)), name: NSNotification.Name("presentAccl") , object: nil)
        //totalAccl = 0.0
        //logAccl = 0.0
        
    }
    @objc func isPresentAccl(notification: NSNotification) {
        DispatchQueue.main.async {
            let meanAcclTime = Date()
            let presentmeanAcclTime = self.date2String(meanAcclTime)
            self.log.text += "Accl = \(logAccl) at \(presentmeanAcclTime)GMT＋08:00. \n"
            //reset the Accl value
            totalAccl = 0.0
        }
    }
    public func date2String(_ date:Date, dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_Hant_TW")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date
    }
}
