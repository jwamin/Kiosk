//
//  ViewController.swift
//  Barista
//
//  Created by Joss Manger on 23/12/2015.
 
//

import UIKit
import Firebase
import AudioToolbox

#if DEBUG
let appURL = "" //FIREBASE DEBUG URL
let debug = true;
#else
let debug = false;
let appURL = "" //FIREBASE LIVE URL
#endif

let kUsernameKey = "uname"

let authEmail = "";

let authPasswd = "";

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
        
    
        
        let url = NSURL(string: "/System/Library/Audio/UISounds/Modern/sms_alert_note.caf")
        
        AudioServicesCreateSystemSoundID(url!, &sound)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name:UIApplicationWillEnterForegroundNotification , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearFirebase", name:UIApplicationWillResignActiveNotification , object: nil)
        MainBase = Firebase(url:appURL)
        //InitialStatus
        checkStatus()
        
        //Start listeners
        drinksListener()
        
        soundSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("sound")
        
    }
    
    override func viewDidLayoutSubviews() {
        print("subviews laid out")
        
    }
    
    func initOnlineLabel(){
        
        statusLabel.text = "Open"
        statusLabel.textColor = UIColor.greenColor()
        
    }
    
    @IBAction func soundSwitchToggle(sender: UISwitch) {
        print("sstoggle")
        let switchValue = soundSwitch.on
        print(switchValue)
        NSUserDefaults.standardUserDefaults().setBool(switchValue, forKey: "sound")
        NSUserDefaults.standardUserDefaults().synchronize()
        print(NSUserDefaults.standardUserDefaults().boolForKey("sound"))
        
    }
    
    func drinksListener(){
        let child = MainBase.childByAppendingPath("orders")
        childObservers.append(child)
        child.observeEventType(.ChildAdded, withBlock: { snapshot in
            
            if snapshot.value is NSNull {
                print("error, no snapshot")
            } else {
                if let newDrink = snapshot.value{
                    
                    if(newDrink["status"] as! String != "done"){
                        self.keys.append(snapshot.key)
                        self.orders[snapshot.key] = newDrink
                        
                        let row = self.keys.count - 1
                        
                        let indexPath = NSIndexPath(forRow: row, inSection: 0)
                        notifiedList.append(snapshot.key)
                        self.table.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                        
                        if(NSUserDefaults.standardUserDefaults().boolForKey("sound")){
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
        
        MainBase.childByAppendingPath("config/status").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if snapshot.value is NSNull {
                print("error, no snapshot")
            } else {
                if let kioskStatus = snapshot.value{
                    
                    let statusBool = (kioskStatus as? String == "open") ? true : false
                    
                    if(statusBool != self.statusSwitch.on){
                        self.statusSwitch.on = statusBool
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
    
    @IBAction func toggleOpen(sender: AnyObject) {
        
        let switchButton = sender as! UISwitch
        
        let status = switchButton.on
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
                    let alery = UIAlertController(title: "Error", message: "There was a problem setting status", preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alery.addAction(action)
                    self.presentViewController(alery, animated: true, completion: nil)
                    
                } else {
                    
                    if let bm = baristaMessage{
                        let messageCommitter = self.MainBase.childByAppendingPath("config/message")
                        messageCommitter.setValue(bm, withCompletionBlock: {
                            
                            (error,base) in
                            
                            if(error != nil){
                                print(error)
                            } else {
                                print("committed successfully")
                            }
                            
                        })
                        
                    }
                    
                    let postRef = self.MainBase.childByAppendingPath("config/status")
                    postRef.setValue(message, withCompletionBlock: {
                        
                        (error,base) in
                        
                        if(error != nil){
                            
                        } else {
                            self.animateLabel(message)
                        }
                        
                    })
                    self.childObservers.append(postRef)
                }
            }
        }
        
        
        if (message == "closed"){
            
            let messagefieldController = UIAlertController(title: "You are closing the Kiosk", message: "Would you like to leave a message?\n (It will be removed when\n you reopen the kiosk)", preferredStyle: UIAlertControllerStyle.Alert)
            messagefieldController.addTextFieldWithConfigurationHandler({
                field in
                field.placeholder = "Write your message here"
                field.autocapitalizationType = .Sentences
            })
            
            let action = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {
                myaction in
                baristaMessage = messagefieldController.textFields![0].text
                closure()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                myaction in
                self.statusSwitch.on = true
            })
            messagefieldController.addAction(action)
            messagefieldController.addAction(cancelAction)
            self.presentViewController(messagefieldController, animated: true, completion: nil)
        } else {
            closure()
        }
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateLabel(message:String){
        if (message == "open"){
            UIView.animateKeyframesWithDuration(1.0, delay: 0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: {
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: {
                    
                    self.statusLabel.layer.position.x = self.statusLabel.layer.position.x - 20
                    
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: {
                    
                    
                    self.statusLabel.layer.opacity = 0
                    
                })
                
                
                }, completion: { bool in
                    self.statusLabel.textColor = UIColor.greenColor()
                    self.statusLabel.text = "Open"
                    UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: {
                        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1.0, animations: {
                            self.statusLabel.layer.position.x = self.statusLabel.layer.position.x + 20
                        })
                        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1.0, animations: {
                            self.statusLabel.layer.opacity = 1
                        })
                        }, completion: { mybool in
                            
                    })
                    
            })
            
        } else if (message == "closed"){
            UIView.animateKeyframesWithDuration(1.0, delay: 0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: {
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: {
                    
                    self.statusLabel.layer.position.x = self.statusLabel.layer.position.x - 20
                    
                })
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: {
                    
                    
                    self.statusLabel.layer.opacity = 0
                    
                })
                
                
                }, completion: { bool in
                    self.statusLabel.textColor = UIColor.redColor()
                    self.statusLabel.text = "Closed"
                    UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: {
                        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1.0, animations: {
                            self.statusLabel.layer.position.x = self.statusLabel.layer.position.x + 20
                        })
                        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1.0, animations: {
                            self.statusLabel.layer.opacity = 1
                        })
                        }, completion: { mybool in
                            
                    })
                    
            })
        }
        
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed("MyTableViewCell", owner: self, options: nil)[0] as? MyTableViewCell
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
        
        cell?.crazylabel.text = string.stringByReplacingOccurrencesOfString("  ", withString: " ")
        
        if let status = orders[keys[indexPath.row]]!["status"] as? String{
            print(status)
            if (status == "in progress"){
                print("rearranging")
                cell?.cellInProgress = true
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    /*
     *#PRAGMA MARK Cell delegate Methods
     *
     */
    
    func cellButtonPressed(cell: MyTableViewCell) {
        let index = table.indexPathForCell(cell)?.row
        let message = "in progress"
        
        MainBase.authUser(authEmail, password: authPasswd) {
            error, authData in
            if error != nil {
                let alery = UIAlertController(title: "Error", message: "There was a problem setting drink status", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                    AlertAction in
                    
                    self.refresh()
                    
                })
                alery.addAction(action)
                self.presentViewController(alery, animated: true, completion: nil)
                
            } else {
                let postRef = self.MainBase.childByAppendingPath("orders/\(self.keys[index!])/status")
                postRef.setValue(message, withCompletionBlock: {
                    
                    (error,base) in
                    
                    if(error != nil){
                        
                    } else {
                        cell.started()
                    }
                    
                })
                self.childObservers.append(postRef)
            }
        }
    }
    
    
    
    
    func cellCompletedPressed(cell: MyTableViewCell) {
        
        let index = table.indexPathForCell(cell)
        let message = "done"
        MainBase.authUser(authEmail, password: authPasswd) {
            error, authData in
            if error != nil {
                let alery = UIAlertController(title: "Error", message: "There was a problem setting completed status", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alery.addAction(action)
                self.presentViewController(alery, animated: true, completion: nil)
                
            } else {
                let postRef = self.MainBase.childByAppendingPath("orders/\(self.keys[index!.row])/status")
                self.childObservers.append(postRef)
                postRef.setValue(message, withCompletionBlock: {
                    
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
    
    func removeCell(cell:MyTableViewCell){
        let index = table.indexPathForCell(cell)
        let key = self.keys[index!.row]
        self.orders.removeValueForKey(key)
        self.keys.removeAtIndex(index!.row)
        print(index)
        self.table.deleteRowsAtIndexPaths([index!], withRowAnimation: .Automatic)
        self.MainBase.childByAppendingPath("orders/\(key)").removeValue()
        
    }
    
    
    func tryPushNotification(cell:MyTableViewCell){
        let index = table.indexPathForCell(cell)
        let key = self.keys[index!.row]
        if let order = self.orders[key]{
            if(order["devicePushKey"] as? String != "nil"){
                
                let pushDeviceID = order["devicePushKey"] as! String
                let drink = order["product"] as! String
                
                let request = NSMutableURLRequest(URL: NSURL(string: "https://jossy-kiosk-apn.herokuapp.com/drinkdone")!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 1.0)
                
                request.HTTPMethod = "POST"
                
                let body = ["drink":drink,"deviceID":pushDeviceID] as Dictionary<String,String>
                
                let serialisedBody : AnyObject
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                do {
                    serialisedBody = try NSJSONSerialization.dataWithJSONObject(body, options: [])
                    request.HTTPBody = serialisedBody as? NSData
                } catch let error as NSError{
                    print(error)
                }
                
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                    (data,response,error) in
                    
                    if(error != nil){
                        print("request error")
                        print(error)
                    } else {
                        print(response,data)
                    }
                
                })
                task.resume()
                
            }
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        checkForCellStatus(cell as! MyTableViewCell)
        
    }
    
    
    func checkForCellStatus(cell:MyTableViewCell){
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

