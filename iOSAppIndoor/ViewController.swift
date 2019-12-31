import UIKit
import AVFoundation
import SwiftSocket
import ProtocolBuffers
import SwiftProtobuf
import CoreData

var timer2 = Timer()
var timer1 = Timer()
var timerToBackForeground : Timer?
var initialButton = false
var callbackToDo = true
var counterToForeground = 0.0
var detecting:Bool = false
var pressStartDetect:Bool = false
var connectToServer:Bool = false
var getNewCS: Bool = false
var kpTime = Int.random(in: -1800...1800) + 3600
let BoostrapServer = UDPClient(address: "140.115.153.209", port: 7777)
var CountryServer = UDPClient(address: "", port: 0)

let queue0 = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
let queue1 = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
let queue2 = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
let queue3 = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)

class ViewController: UIViewController {
    
    @IBOutlet weak var lowPowerMode: UILabel!
    @IBOutlet weak var QRCodeGen: UIButton!
    @IBOutlet weak var display: UIButton!
    @IBOutlet weak var illustration: UIButton!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var presentForDetectingShaking: UIImageView!
    @IBOutlet weak var presentForReceivingingShaking: UIImageView!
    @IBOutlet weak var presentLog: UIButton!
    @IBOutlet weak var deleteTokens: UIButton!
    @IBOutlet weak var detectAccl: UISwitch!
    @IBOutlet weak var presentAcclStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        timerToBackForeground = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(self.prozessTimer), userInfo: nil, repeats: true)
        UIApplication.shared.isIdleTimerDisabled = true
        lowPowerMode.isHidden = true
        presentForDetectingShaking.isHidden = true
        presentForReceivingingShaking.isHidden = true
        deleteTokens.isHidden = true
        
        //Initialize presentation of Buttons
        if initialButton == false{
            initialButton = true
            display.setTitle("Off", for: .normal)
            display.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            display.backgroundColor = UIColor.init(red: 244/255.0, green: 54/255.0, blue: 60/255.0, alpha: 0.65)
        }
        if pressStartDetect{
            presentAcclStatus.text = "Detecting"
            detectAccl.setOn(true, animated: false)
            self.display.setTitle("On", for: .normal)
            self.display.backgroundColor = UIColor.init(red: 54/255.0, green: 244/255.0, blue: 60/255.0, alpha: 0.65)
        }else{
            presentAcclStatus.text = "Undetected"
            detectAccl.setOn(false, animated: false)
            display.setTitle("Off", for: .normal)
            display.backgroundColor = UIColor.init(red: 244/255.0, green: 54/255.0, blue: 60/255.0, alpha: 0.65)
        }
        
        //Write coredata into Array
        fetchToken()
        
        //Connect with Server
        queue0.async {
            if connectToServer == false{
                connectToServer = true
                bootAsk()
                print("Connect with bootstrapServer")
                let unpacket3 = recvDataFromBoot()
                print(unpacket3.PacketType.packetType)
                let decodeData3 = try! BootAsk.parseFrom(data: unpacket3.recvProto as Data)
                print(decodeData3)
                let countryServer = UDPClient(address: decodeData3.serverIp, port: decodeData3.serverPort)
                CountryServer = countryServer
                print(CountryServer.address,CountryServer.port)
                kpAliveAck()
                
                //kpAlive with CS
                queue1.async {
                    while true{
                        countCSResponse = 0
                        getCSResponse = false
                        while countCSResponse < 3{
                            kpAlive()
                            sleep(3)
                            if getCSResponse{
                                print("Receive countryServer response")
                                countCSResponse = 3
                            }else{
                                countCSResponse += 1
                            }
                        }
                        if getCSResponse{
                            getNewCS = true
                        }else{
                            requestNewCS()
                        }
                        sleep(3)
                        if getNewCS{
                            getNewCS = false
                        }else{
                            print("Cannot connect with bootstrapServer")
                            print("Please restart the application")
                        }
                        sleep(UInt32(kpTime))
                    }
                }
                
                //Send shakingAlert packet to CS.
                queue2.async{
                    while true{
                        let unpacket = recvDataFromServer()
                        print(unpacket.PacketType.packetType)
                        chooseProto(packetType: unpacket.PacketType, recvProto: unpacket.recvProto)
                        if unpacket.PacketType.packetType == "2"{
                            queue3.async{
                                Alert()
                                let alertController = UIAlertController(title: "Warning", message: "Detect Shacking", preferredStyle: UIAlertController.Style.alert)
                                let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                                    stopAlert()
                                }
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Reset reciprocal of backToForeground.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event?.allTouches?.first {
            let loc:CGPoint = touch.location(in: touch.view)
            print(" X:\(loc.x) Y:\(loc.y) ")
            counterToForeground = 0
        }
    }
    
    //Fetch coredata
    func fetchToken(){
        //Load AppDelegate
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Token")
        fetchRequest.fetchLimit = 4
        do {
            let result = try context.fetch(fetchRequest)
            var l = 0
            for data in result as! [NSManagedObject]{
                print(data.value(forKey: "token") as! String)
                deviceToken[l] = (data.value(forKey: "token") as! String)
                l += 1
                if l > 3{
                    l = 0
                }
            }
        }catch {
            print("Failed")
        }
        print(deviceToken)
    }
    
    //Delete coredata
    func deleteToken(){
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Token")
        if deviceToken[0] != "0"{
            for k in 0...(deviceToken.count - 1){
                print(deviceToken[k])
                fetchRequest.predicate = NSPredicate(format: "token = %@", deviceToken[k])
                
                do{
                    let test = try context.fetch(fetchRequest)
                    
                    let objectToDelete = test[0] as! NSManagedObject
                    context.delete(objectToDelete)
                    do {
                        try context.save()
                    } catch  {
                        print(error)
                    }
                }catch{
                    print(error)
                }
            }
        }else{
            print("There are no token")
        }
        deviceToken = ["0"]
        print(deviceToken)
    }
    
    //Receive callback to present alert images.
    @objc func timerAction() {
        Downloader().fetechData {
            //<--- callback variable of function.
            (progress) -> Void in
            //<--- callback content of function.
            if progress == 1{
                print("Detection is false.")
                self.presentForDetectingShaking.isHidden = false
                timer2 = Timer.scheduledTimer(timeInterval:5 , target: self, selector: #selector(self.pressForCancelImage), userInfo: nil, repeats: true)
            }
        }
    }
    
    //Receive callback to cancel detection.
    @objc func timerAction1() {
        Downloader1().fetechData {
            //<--- callback variable of function.
            (progress) -> Void in
            //<--- callback content of function.
            if progress == 1{
                print("Alert user Accl.")
                self.presentAcclStatus.text = "Do not move."
                self.display.setTitle("Wait..", for: .normal)
                self.display.backgroundColor = UIColor.init(red: 241/255.0, green: 213/255.0, blue: 30/255.0, alpha: 0.65)
                self.display.dim()
                self.display.wiggle()
                timer2 = Timer.scheduledTimer(timeInterval:10 , target: self, selector: #selector(self.acclStatusLabel), userInfo: nil, repeats: true)
            }
        }
    }
    
    //Cancel detection Image
    //If send right alert packet, present receiving image.
    @objc func pressForCancelImage(){
        self.presentForDetectingShaking.isHidden = true
        if sendCorrectEqEvent{
            sendCorrectEqEvent = false
            print("Detection is true.")
            self.presentForReceivingingShaking.isHidden = false
            timer2 = Timer.scheduledTimer(timeInterval:5 , target: self, selector: #selector(self.cancelImage), userInfo: nil, repeats: true)
        }
    }
    
    //present Accl status
    @objc func acclStatusLabel(){
        pressStartDetect = false
        self.detectAccl.setOn(false, animated: true)
        self.presentAcclStatus.text = "Undetected"
        display.setTitle("Off", for: .normal)
        display.backgroundColor = UIColor.init(red: 244/255.0, green: 54/255.0, blue: 60/255.0, alpha: 0.65)
    }
    @objc func cancelImage(){
        self.presentForReceivingingShaking.isHidden = true
    }
    
    //switch fore and background
    @objc func prozessTimer() {
        counterToForeground += 1
        if counterToForeground > 30{
            background.isHidden = true
            lowPowerMode.isHidden = false
            QRCodeGen.isHidden = true
            display.isHidden = true
            detectAccl.isHidden = true
            illustration.isHidden = true
            presentLog.isHidden = true
            presentAcclStatus.isHidden = true
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }else{
            presentLog.isHidden = false
            background.isHidden = false
            lowPowerMode.isHidden = true
            QRCodeGen.isHidden = false
            display.isHidden = false
            presentAcclStatus.isHidden = false
            detectAccl.isHidden = false
            illustration.isHidden = false
        }
    }
    @IBAction func deleteTokens(_ sender: Any) {
        deleteToken()
        print("Complete deleting tokens.")
        fetchToken()
    }
    
    //switch bar status
    @IBAction func detectAccl(_ sender: UISwitch) {
        if sender.isOn == true{
            presentAcclStatus.text = "Detecting"
            print("On")
            //main thread for UItext
            if pressStartDetect == false{
                pressStartDetect = true
                DispatchQueue.main.async {
                    startAcclUpdate()
                }
                print("time1：", Date())
                if detecting == false{
                    detecting = true
                    self.display.setTitle("Wait..", for: .normal)
                    self.display.backgroundColor = UIColor.init(red: 241/255.0, green: 213/255.0, blue: 30/255.0, alpha: 0.65)
                    self.display.dim()
                    self.display.wiggle()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 7) {
                        print("time2：", Date())
                        self.display.setTitle("On", for: .normal)
                        self.display.backgroundColor = UIColor.init(red: 54/255.0, green: 244/255.0, blue: 60/255.0, alpha: 0.65)
                        self.display.dim()
                        self.display.wiggle()
                    }
                }else{
                    self.display.setTitle("On", for: .normal)
                    self.display.backgroundColor = UIColor.init(red: 54/255.0, green: 244/255.0, blue: 60/255.0, alpha: 0.65)
                    self.display.dim()
                    self.display.wiggle()
                }
                if callbackToDo {
                    //play
                    callbackToDo = false
                    timer1 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
                    timer2 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerAction1), userInfo: nil, repeats: true)
                }
            }
        }else{
            if callbackToDo == false{
                callbackToDo = true
                timer1.invalidate()
            }
            presentAcclStatus.text = "Undetected"
            display.setTitle("Off", for: .normal)
            display.backgroundColor = UIColor.init(red: 244/255.0, green: 54/255.0, blue: 60/255.0, alpha: 0.65)
            display.dim()
            display.wiggle()
            if pressStartDetect{
                pressStartDetect = false
                stopAcclUpdate()
                print("Already stop detecting")
                
            }
        }
    }
}



