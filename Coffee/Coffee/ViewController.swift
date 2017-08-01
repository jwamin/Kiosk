//
//  ViewController.swift
//  Coffee
//
//  Created by Joss Manger on 23/12/2015.
 
//

import UIKit
import Firebase

class ViewController: UIViewController, newuserProtocolDelegate {
    
    //MARK: - Instance Variables and ViewController Methods
    
    //Local Variables
    var MainBase:Firebase!
    var statusListener:Firebase!
    var drinksListener:Firebase!
    var configListener:Firebase!
    
    var currentOrder:String? = nil

    //Interface Builder Outlets (@IBOutlet)
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var newDrinkBig: UIButton!
    @IBOutlet var favButton: UIButton!
    @IBOutlet var statusMessage: UILabel!
    @IBOutlet var thanksBig: UIButton!
    
    //Status Flags
    var checkCalled:Bool = false
    var receivedDone:Bool = false
    var bases:[Firebase] = []
    var active:Bool = true;
    
    var connectionMonitor:UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if(keyAlreadyExist(kUsernameKey)){
            initMain()
        } else {
            let stb = UIStoryboard(name: "Main", bundle: nil)
            let vc = stb.instantiateViewControllerWithIdentifier("nouser") as! AddUser
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        if(debug){
            print("debug enabled")
            connectionMonitor = UIView(frame: CGRect(x: 0, y: 70, width: 50, height: 50))
            self.view.addSubview(connectionMonitor!)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if(keyAlreadyExist(orderIDk)){
            //newDrink.enabled = false;
            currentOrder = NSUserDefaults.standardUserDefaults().objectForKey(orderIDk) as? String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //'Main' method called on view load
    func initMain(){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        becameActive()
        addNotifications()
        subscribeToConnectedState()
    }

    //MARK: - NSNotifications and handlers

    
    func addNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resigned", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "becameActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    //#MARK: - Notification Handlers
    //detach and attach app functionality following NSNotification
    
    
    //remove all Firebase listening functionality
    func resigned(){
        print("leaving")
        checkCalled = false;
        
        MainBase.removeAllObservers()
        statusListener.removeAllObservers()
        if (drinksListener != nil){
            drinksListener.removeAllObservers()
        }
        configListener.removeAllObservers()
    }
    
    //active = true
    
    //re-attach listeners for all data
    func becameActive(){
        print("entered")
        statusMessage.hidden = true
        activity.stopAnimating()
        print("initialising bases")
        MainBase = Firebase(url: appURL)
        subscribeToStatus()
        getConfig()
        // Get the data on a post that has changed
        if(keyAlreadyExist(orderIDk)){
            //newDrink.enabled = false;
            currentOrder = NSUserDefaults.standardUserDefaults().objectForKey(orderIDk) as? String
            subscribeToMyDrink()
        }
        
    }
    
    //MARK: - Firebase attach methods
    
    //Connectivity status method
    
    func subscribeToConnectedState() -> Void{
        let infoConnected = MainBase.childByAppendingPath(".info/connected")
        infoConnected.observeEventType(FEventType.Value, withBlock: { snapshot in
            
            if snapshot.value is NSNull {
                print("error")
            } else {
                let connected = snapshot.value as? Bool
                if connected != nil && connected! {
                    NSLog("connected")
                    self.newDrinkBig.enabled = true
                    self.newDrinkBig.setTitle("New Drink", forState: .Normal)
                    self.newDrinkBig.layer.opacity = 1.0
                    self.favButton.enabled = true
                    self.favButton.hidden = true
                    self.active = true
                    self.connectionMonitor?.backgroundColor = UIColor.greenColor()
                } else {
                    NSLog("Not connected")
                    self.newDrinkBig.enabled = false
                    self.newDrinkBig.setTitle("Disabled", forState: .Normal)
                    self.newDrinkBig.layer.opacity = 0.5
                    self.favButton.enabled = false
                    self.favButton.hidden = true
                    self.active = false
                    self.connectionMonitor?.backgroundColor = UIColor.redColor()
                }
                
            }
            
        })
        
    }
    
    //Status method
    
    func subscribeToStatus()->Void{
        statusListener = MainBase.childByAppendingPath("config")
        statusListener.observeEventType(FEventType.Value, withBlock: { snapshot in
            
            if snapshot.value is NSNull {
                print("error")
            } else {
                if let status = snapshot.value.objectForKey("status"){
                    let stat = status as! String
                    if (stat=="closed"){
                        let stb = UIStoryboard(name: "Main", bundle: nil)
                        let vc = stb.instantiateViewControllerWithIdentifier("closed") as! closed
                        if let text = snapshot.value.objectForKey("message") as? String{
                            vc.text = text
                        }
                        self.presentViewController(vc, animated: true, completion: nil)
                    }
                } else {
                    print("error")
                }
                
            }
            
        })
    
        
    }

    //Gets the drinks settings from Firebase as sticks in a global object for use in the next ViewController
    
    func getConfig() {
        configListener = MainBase.childByAppendingPath("config")
        configListener.observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
            
            if snapshot.value is NSNull {
                print("error")
            } else {
                
                //gets drinks and settings
                if let returnedDrinks = snapshot.value.objectForKey("drinks"){
                    var drinkList:Array<Dictionary<String,AnyObject>> = []
                    if let returnedDrinkData = returnedDrinks as? Dictionary<String,Dictionary<String,AnyObject>>{
                        for (key,value) in returnedDrinkData {
                            drinkList.append(value)
                        }
                    }
                    
                
                    
                    drinks = drinkList
                } else {
                    print("error")
                }
                
                //Gets available syrups object
                if let returnedSyrups = snapshot.value.objectForKey("syrup"){
                    let returnedSyrupData = returnedSyrups
                    syrups = returnedSyrupData as! [String]
                } else {
                    print("error")
                }
                if(!keyAlreadyExist(orderIDk)){
                    //self.newDrink.enabled = true
                    self.newDrinkBig.hidden = false;
                    if(keyAlreadyExist(favourite)){
                        self.favButton.hidden = false
                    }
                }
                
            }
            
        })
    }
    
    //#MARK: - IBActions
    
    @IBAction func orderFav(){
        let fav = NSUserDefaults.standardUserDefaults().objectForKey(favourite) as? NSDictionary
        postOrder(fav!)
    }
    
    //#MARK: - Submit Drink to Firebase
    
    func postOrder(data:NSDictionary){
        
        var postData:[String:AnyObject] = data as! [String:AnyObject]
        postData["name"] = NSUserDefaults.standardUserDefaults().valueForKey(kUsernameKey)
        postData["time"] = FirebaseServerValue.timestamp()
        
        if(keyAlreadyExist("devicePushKey")){
            postData["devicePushKey"] = getExistingValue("devicePushKey");
        } else {
            postData["devicePushKey"] = "nil";
        }
        
        MainBase.authUser(authEmail, password: authPasswd) {
            error, authData in
            if error != nil {
                let alery = UIAlertController(title: "Error", message: "There was a problem with your order", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alery.addAction(action)
                self.presentViewController(alery, animated: true, completion: nil)
            } else {
                let postRef = self.MainBase.childByAppendingPath("orders")
                let post1Ref = postRef.childByAutoId()
                post1Ref.setValue(postData)
                self.currentOrder = post1Ref.key
                //self.newDrink.enabled = false;
                self.newDrinkBig.hidden = true;
                self.favButton.hidden = true;
                NSUserDefaults.standardUserDefaults().setObject(self.currentOrder, forKey: orderIDk)
                self.subscribeToMyDrink()
            }
        }
        
        
        
    }
    
    //#MARK: - Listen for remote changes on drink
    
    func subscribeToMyDrink() -> Void{
        if(checkCalled==false){
            
        drinksListener = MainBase.childByAppendingPath("orders/"+currentOrder!)
        drinksListener.observeEventType(FEventType.Value, withBlock: { snapshot in
            print(self.active)
            if(self.active){
            if snapshot.value is NSNull {
                print("was null")
                self.clearBases()
                if(!self.receivedDone){
                    self.clearInterface()
                }
                
            } else {
                
                self.updateViews(snapshot)
            }
            }
        })
    }
    }
    
    
    //#MARK: - Update UI Methods
    
    func updateViews(snapshot:FDataSnapshot) -> Void{

        if snapshot.value is NSNull {
            self.activity.stopAnimating()
            self.statusMessage.text = "Your drink is ready!"
            self.receivedDone = true
            self.thanksBig.hidden = false;
        } else {
        
        if let value = snapshot.value.objectForKey("status") as? String{
        let drink = snapshot.value.objectForKey("product") as! String
        NSLog(value)
        //self.newDrink.enabled = false
        self.newDrinkBig.hidden = true;
            self.thanksBig.hidden = true;
            if(keyAlreadyExist(favourite)){
                self.favButton.hidden = true
            }
        self.statusMessage.hidden = false;
        if(value=="pending"){
            self.activity.stopAnimating()
            self.statusMessage.text = "Your order has been received"
        }
            
        if(value=="in progress"){
            self.activity.startAnimating()
            self.statusMessage.text = "Your \(drink) is being prepared"
        }
        
        if(value=="done"){
            self.activity.stopAnimating()
            self.statusMessage.text = "Your \(drink) is ready!"
            self.receivedDone = true
            self.thanksBig.hidden = false;
      
        }
            }
        }


    }
    
    
    @IBAction func ThanksButtonPressed(){
        clearInterface()
        resetDone()
    }
    
    
    @IBAction func clearInterface(){
        self.statusMessage.hidden = true;
        self.activity.stopAnimating()
        self.newDrinkBig.hidden = false;
        
        if(keyAlreadyExist(favourite)){
            self.favButton.hidden = false
        }
        
        self.receivedDone = false
        self.thanksBig.hidden = true;
        
    }
    
    func resetDone(){
        drinksListener.removeAllObservers()
        NSUserDefaults.standardUserDefaults().removeObjectForKey(orderIDk)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(notificationReceived)
    }
    
    func clearBases(){
        print("clearing bases")
        checkCalled = false;
        MainBase.removeAllObservers()
        statusListener.removeAllObservers()
        drinksListener.removeAllObservers()
        configListener.removeAllObservers()
        let removeer = MainBase.childByAppendingPath("orders/"+currentOrder!) as Firebase
        removeer.removeValue()
        removeer.removeAllObservers()
        NSUserDefaults.standardUserDefaults().removeObjectForKey(orderIDk)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(notificationReceived)
    }
    

    
    //MARK: - addUser delegate methods
    func returnedUser() {
        initMain()
    }
    
}

