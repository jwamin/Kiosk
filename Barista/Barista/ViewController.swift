//
//  ViewController.swift
//  Barista
//
//  Created by Joss Manger on 23/12/2015.
 
//

import UIKit
import Firebase
import AudioToolbox



let kUsernameKey = "uname"

let orderIDk = "orderID"

var notifiedList:[String] = []

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, tableCellControlDelegate{
    
    var orders:Dictionary<String,AnyObject> = [:]
    var keys:Array<String> = []
    var keysOld:Array<String> = []
    @IBOutlet var statusSwitch: UISwitch!
    var MainBase:Firebase!
    
    var childObservers:[Firebase] = []
    
    @IBOutlet var table: UITableView!
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var soundSwitch: UISwitch!
    var sound:SystemSoundID = 0
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var adminButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(appURL)
        
    
        
        let url = URL(string: "/System/Library/Audio/UISounds/Modern/sms_alert_note.caf")
        
        AudioServicesCreateSystemSoundID(url! as CFURL, &sound)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.refresh), name:NSNotification.Name.UIApplicationWillEnterForeground , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.clearFirebase), name:NSNotification.Name.UIApplicationWillResignActive , object: nil)
        MainBase = Firebase(url:appURL)
        //InitialStatus
        checkStatus()
        
        //Start listeners
        drinksListener()
        
        soundSwitch.isOn = UserDefaults.standard.bool(forKey: "sound")
        
    }
    
    override func viewDidLayoutSubviews() {
        print("subviews laid out")
        
    }
    
    func initOnlineLabel(){
        
        statusLabel.text = "Open"
        statusLabel.textColor = UIColor.green
        
    }
    
    @IBAction func soundSwitchToggle(_ sender: UISwitch) {
        print("sstoggle")
        let switchValue = soundSwitch.isOn
        print(switchValue)
        UserDefaults.standard.set(switchValue, forKey: "sound")
        UserDefaults.standard.synchronize()
        print(UserDefaults.standard.bool(forKey: "sound"))
        
    }
    
    func drinksListener(){
        let child = MainBase.child(byAppendingPath: "orders")
        childObservers.append(child!)
        child?.observe(.childAdded, with: { snapshot in
            
            if snapshot?.value is NSNull {
                print("error, no snapshot")
            } else {
                if let newDrink = snapshot?.value as? [String:Any]{
                    
                    if(newDrink["status"] as! String != "done"){
                        self.keys.append((snapshot?.key)!)
                        self.orders[(snapshot?.key)!] = newDrink as AnyObject
                        
                        let row = self.keys.count - 1
                        
                        let indexPath = IndexPath(row: row, section: 0)
                        notifiedList.append((snapshot?.key)!)
                        self.table.insertRows(at: [indexPath], with: .top)
                        
                        if(UserDefaults.standard.bool(forKey: "sound")){
                            AudioServicesPlaySystemSound(self.sound);
                        }
                        
                    }
                    
                } else {
                    print("error")
                }
                
            }
            
        })
        
    }
    
    func checkStatus(){
        
        MainBase.child(byAppendingPath: "config/status").observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot?.value is NSNull {
                print("error, no snapshot")
            } else {
                if let kioskStatus = snapshot?.value{
                    
                    let statusBool = (kioskStatus as? String == "open") ? true : false
                    
                    if(statusBool != self.statusSwitch.isOn){
                        self.statusSwitch.isOn = statusBool
                    }
                    var message = ""
                    switch(statusBool){
                    case false:
                        message = "closed"
                        break;
                    case true:
                        message = "open"
                    }
                    self.animateLabel(message)
                    
                } else {
                    print("error, no orders")
                }
                
            }
            
        })
        
    }
    
    @IBAction func toggleOpen(_ sender: AnyObject) {
        
        let switchButton = sender as! UISwitch
        
        let status = switchButton.isOn
        var message = "";
        switch(status){
        case false:
            message = "closed"
            break;
        case true:
            message = "open"
        }
        var baristaMessage:String? = nil
        
        let closure = {
            self.MainBase.authUser(authEmail, password: authPasswd) {
                error, authData in
                if error != nil {
                    let alery = UIAlertController(title: "Error", message: "There was a problem setting status", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alery.addAction(action)
                    self.present(alery, animated: true, completion: nil)
                    
                } else {
                    
                    if let bm = baristaMessage{
                        let messageCommitter = self.MainBase.child(byAppendingPath: "config/message")
                        messageCommitter?.setValue(bm, withCompletionBlock: {
                            
                            (error,base) in
                            
                            if(error != nil){
                                print(error)
                            } else {
                                print("committed successfully")
                            }
                            
                        })
                        
                    }
                    
                    let postRef = self.MainBase.child(byAppendingPath: "config/status")
                    postRef?.setValue(message, withCompletionBlock: {
                        
                        (error,base) in
                        
                        if(error != nil){
                            
                        } else {
                            self.animateLabel(message)
                        }
                        
                    })
                    self.childObservers.append(postRef!)
                }
            }
        }
        
        
        if (message == "closed"){
            
            let messagefieldController = UIAlertController(title: "You are closing the Kiosk", message: "Would you like to leave a message?\n (It will be removed when\n you reopen the kiosk)", preferredStyle: UIAlertControllerStyle.alert)
            messagefieldController.addTextField(configurationHandler: {
                field in
                field.placeholder = "Write your message here"
                field.autocapitalizationType = .sentences
            })
            
            let action = UIAlertAction(title: "Submit", style: UIAlertActionStyle.default, handler: {
                myaction in
                baristaMessage = messagefieldController.textFields![0].text
                closure()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
                myaction in
                self.statusSwitch.isOn = true
            })
            messagefieldController.addAction(action)
            messagefieldController.addAction(cancelAction)
            self.present(messagefieldController, animated: true, completion: nil)
        } else {
            closure()
        }
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateLabel(_ message:String){
        if (message == "open"){
            UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                    
                    self.statusLabel.layer.position.x = self.statusLabel.layer.position.x - 20
                    
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                    
                    
                    self.statusLabel.layer.opacity = 0
                    
                })
                
                
                }, completion: { bool in
                    self.statusLabel.textColor = UIColor.green
                    self.statusLabel.text = "Open"
                    UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                            self.statusLabel.layer.position.x = self.statusLabel.layer.position.x + 20
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                            self.statusLabel.layer.opacity = 1
                        })
                        }, completion: { mybool in
                            
                    })
                    
            })
            
        } else if (message == "closed"){
            UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                    
                    self.statusLabel.layer.position.x = self.statusLabel.layer.position.x - 20
                    
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                    
                    
                    self.statusLabel.layer.opacity = 0
                    
                })
                
                
                }, completion: { bool in
                    self.statusLabel.textColor = UIColor.red
                    self.statusLabel.text = "Closed"
                    UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                            self.statusLabel.layer.position.x = self.statusLabel.layer.position.x + 20
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                            self.statusLabel.layer.opacity = 1
                        })
                        }, completion: { mybool in
                            
                    })
                    
            })
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("MyTableViewCell", owner: self, options: nil)?[0] as? MyTableViewCell
        cell?.delegate = self
        
        if(debug){
            print(orders[keys[indexPath.row]]!)
        }
        
        let drink = orders[keys[indexPath.row]]!["product"] as! String
        
        let person = orders[keys[indexPath.row]]!["name"] as! String
        
        let shotNumber = Int(orders[keys[indexPath.row]]!["shots"] as! String)!
        var shotString = "";
        switch (shotNumber){
        case 0:
            shotString = "Half Shot"
            break
        case 2:
            shotString = "Double"
            break
        case 3:
            shotString = "Triple"
            break
        default:
            shotString = ""
        }
        
        let styleString = orders[keys[indexPath.row]]!["style"] as! String
        let printStyle = (styleString == "Regular") ? "" : styleString
        
        let syrup = orders[keys[indexPath.row]]!["syrup"] as! String
        let printSyrup = (syrup == "None") ? "" : syrup
        
        let string = "\(printStyle) \(shotString) \(printSyrup) \(drink) for \(person)"
        
        cell?.crazylabel.text = string.replacingOccurrences(of: "  ", with: " ")
        
        if let status = orders[keys[indexPath.row]]!["status"] as? String{
            print(status)
            if (status == "in progress"){
                print("rearranging")
                cell?.cellInProgress = true
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    /*
     *#PRAGMA MARK Cell delegate Methods
     *
     */
    
    func cellButtonPressed(_ cell: MyTableViewCell) {
        let index = table.indexPath(for: cell)?.row
        let message = "in progress"
        
        MainBase.authUser(authEmail, password: authPasswd) {
            error, authData in
            if error != nil {
                let alery = UIAlertController(title: "Error", message: "There was a problem setting drink status", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                    AlertAction in
                    
                    self.refresh()
                    
                })
                alery.addAction(action)
                self.present(alery, animated: true, completion: nil)
                
            } else {
                let postRef = self.MainBase.child(byAppendingPath: "orders/\(self.keys[index!])/status")
                postRef?.setValue(message, withCompletionBlock: {
                    
                    (error,base) in
                    
                    if(error != nil){
                        
                    } else {
                        cell.started()
                    }
                    
                })
                self.childObservers.append(postRef!)
            }
        }
    }
    
    
    
    
    func cellCompletedPressed(_ cell: MyTableViewCell) {
        
        let index = table.indexPath(for: cell)
        let message = "done"
        MainBase.authUser(authEmail, password: authPasswd) {
            error, authData in
            if error != nil {
                let alery = UIAlertController(title: "Error", message: "There was a problem setting completed status", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alery.addAction(action)
                self.present(alery, animated: true, completion: nil)
                
            } else {
                let postRef = self.MainBase.child(byAppendingPath: "orders/\(self.keys[index!.row])/status")
                self.childObservers.append(postRef!)
                postRef?.setValue(message, withCompletionBlock: {
                    
                    (error,base) in
                    
                    if(error != nil){
                        print(error)
                    } else {
                        cell.animateEnd()
                        
                        self.tryPushNotification(cell)
                        
                    }
                    
                })
                
            }
        }
    }
    
    func removeCell(_ cell:MyTableViewCell){
        let index = table.indexPath(for: cell)
        let key = self.keys[index!.row]
        self.orders.removeValue(forKey: key)
        self.keys.remove(at: index!.row)
        print(index)
        self.table.deleteRows(at: [index!], with: .automatic)
        self.MainBase.child(byAppendingPath: "orders/\(key)").removeValue()
        
    }
    
    
    func tryPushNotification(_ cell:MyTableViewCell){
        let index = table.indexPath(for: cell)
        let key = self.keys[index!.row]
        if let order = self.orders[key]{
            if(order["devicePushKey"] as? String != "nil"){
                
                let pushDeviceID = order["devicePushKey"] as! String
                let drink = order["product"] as! String
                
                let request = NSMutableURLRequest(url: URL(string: "https://jossy-kiosk-apn.herokuapp.com/drinkdone")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 1.0)
                
                request.httpMethod = "POST"
                
                let body = ["drink":drink,"deviceID":pushDeviceID] as Dictionary<String,String>
                
                let serialisedBody : AnyObject
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                do {
                    serialisedBody = try JSONSerialization.data(withJSONObject: body, options: []) as AnyObject
                    request.httpBody = serialisedBody as? Data
                } catch let error as NSError{
                    print(error)
                }
                
//                let task = URLSession.shared.dataTask(with: request, completionHandler: {
//                    (data,response,error) in
//                    
//                    if(error != nil){
//                    print("request error")
//                    print(error)
//                    } else {
//                    print(response,data)
//                    }
//                })
//                
//                task.resume()
//                
            }
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        checkForCellStatus(cell as! MyTableViewCell)
        
    }
    
    
    func checkForCellStatus(_ cell:MyTableViewCell){
        if let cellstatus = cell.cellInProgress{
            if(cellstatus == true){
                cell.statusRearrange()
            }
        }
    }
    
    func clearFirebase(){
        print("firebase cleared")
        orders = [:]
        keys = []
        table.reloadData()
        MainBase.removeAllObservers()
        for base in childObservers{
            base.removeAllObservers()
        }
    }
    
    @IBAction func refresh(){
        
        notifiedList = []
        print("refresh called")
        clearFirebase()
        checkStatus()
        drinksListener()
        
    }
    
}

