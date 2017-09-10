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
            let vc = stb.instantiateViewController(withIdentifier: "nouser") as! AddUser
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
        if(debug){
            print("debug enabled")
            connectionMonitor = UIView(frame: CGRect(x: 0, y: 70, width: 50, height: 50))
            self.view.addSubview(connectionMonitor!)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(keyAlreadyExist(orderIDk)){
            //newDrink.enabled = false;
            currentOrder = UserDefaults.standard.object(forKey: orderIDk) as? String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //'Main' method called on view load
    func initMain(){
        UIApplication.shared.cancelAllLocalNotifications()
        becameActive()
        addNotifications()
        subscribeToConnectedState()
    }

    //MARK: - NSNotifications and handlers

    
    func addNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.resigned), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.becameActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
        statusMessage.isHidden = true
        activity.stopAnimating()
        print("initialising bases")
        MainBase = Firebase(url: appURL)
        subscribeToStatus()
        getConfig()
        // Get the data on a post that has changed
        if(keyAlreadyExist(orderIDk)){
            //newDrink.enabled = false;
            currentOrder = UserDefaults.standard.object(forKey: orderIDk) as? String
            subscribeToMyDrink()
        }
        
    }
    
    //MARK: - Firebase attach methods
    
    //Connectivity status method
    
    func subscribeToConnectedState() -> Void{
        let infoConnected = MainBase.child(byAppendingPath: ".info/connected")
        infoConnected?.observe(FEventType.value, with: { snapshot in
            
            if snapshot?.value is NSNull {
                print("error")
            } else {
                let connected = snapshot?.value as? Bool
                if connected != nil && connected! {
                    NSLog("connected")
                    self.newDrinkBig.isEnabled = true
                    self.newDrinkBig.setTitle("New Drink", for: UIControlState())
                    self.newDrinkBig.layer.opacity = 1.0
                    self.favButton.isEnabled = true
                    self.favButton.isHidden = true
                    self.active = true
                    self.connectionMonitor?.backgroundColor = UIColor.green
                } else {
                    NSLog("Not connected")
                    self.newDrinkBig.isEnabled = false
                    self.newDrinkBig.setTitle("Disabled", for: UIControlState())
                    self.newDrinkBig.layer.opacity = 0.5
                    self.favButton.isEnabled = false
                    self.favButton.isHidden = true
                    self.active = false
                    self.connectionMonitor?.backgroundColor = UIColor.red
                }
                
            }
            
        })
        
    }
    
    //Status method
    
    func subscribeToStatus()->Void{
        statusListener = MainBase.child(byAppendingPath: "config")
        statusListener.observe(FEventType.value, with: { snapshot in
            
            if snapshot?.value is NSNull {
                print("error")
            } else {
                if let status = (snapshot?.value as AnyObject).object(forKey: "status"){
                    let stat = status as! String
                    if (stat=="closed"){
                        let stb = UIStoryboard(name: "Main", bundle: nil)
                        let vc = stb.instantiateViewController(withIdentifier: "closed") as! closed
                        if let text = (snapshot?.value as AnyObject).object(forKey: "message") as? String{
                            vc.text = text
                        }
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
                    print("error")
                }
                
            }
            
        })
    
        
    }

    //Gets the drinks settings from Firebase as sticks in a global object for use in the next ViewController
    
    func getConfig() {
        configListener = MainBase.child(byAppendingPath: "config")
        configListener.observeSingleEvent(of: FEventType.value, with: { snapshot in
            
            if snapshot?.value is NSNull {
                print("error")
            } else {
                
                //gets drinks and settings
                if let returnedDrinks = (snapshot?.value as AnyObject).object(forKey: "drinks"){
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
                if let returnedSyrups = (snapshot?.value as AnyObject).object(forKey: "syrup"){
                    let returnedSyrupData = returnedSyrups
                    syrups = returnedSyrupData as! [String]
                } else {
                    print("error")
                }
                if(!keyAlreadyExist(orderIDk)){
                    //self.newDrink.enabled = true
                    self.newDrinkBig.isHidden = false;
                    if(keyAlreadyExist(favourite)){
                        self.favButton.isHidden = false
                    }
                }
                
            }
            
        })
    }
    
    //#MARK: - IBActions
    
    @IBAction func orderFav(){
        let fav = UserDefaults.standard.object(forKey: favourite) as? NSDictionary
        postOrder(fav!)
    }
    
    //#MARK: - Submit Drink to Firebase
    
    func postOrder(_ data:NSDictionary){
        
        var postData:[String:AnyObject] = data as! [String:AnyObject]
        postData["name"] = UserDefaults.standard.value(forKey: kUsernameKey) as AnyObject
        postData["time"] = FirebaseServerValue.timestamp() as AnyObject
        
        if(keyAlreadyExist("devicePushKey")){
            postData["devicePushKey"] = getExistingValue("devicePushKey");
        } else {
            postData["devicePushKey"] = "nil" as AnyObject;
        }
        
        MainBase.authUser(authEmail, password: authPasswd) {
            error, authData in
            if error != nil {
                let alery = UIAlertController(title: "Error", message: "There was a problem with your order", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alery.addAction(action)
                self.present(alery, animated: true, completion: nil)
            } else {
                let postRef = self.MainBase.child(byAppendingPath: "orders")
                let post1Ref = postRef?.childByAutoId()
                post1Ref?.setValue(postData)
                self.currentOrder = post1Ref?.key
                //self.newDrink.enabled = false;
                self.newDrinkBig.isHidden = true;
                self.favButton.isHidden = true;
                UserDefaults.standard.set(self.currentOrder, forKey: orderIDk)
                self.subscribeToMyDrink()
            }
        }
        
        
        
    }
    
    //#MARK: - Listen for remote changes on drink
    
    func subscribeToMyDrink() -> Void{
        if(checkCalled==false){
            
        drinksListener = MainBase.child(byAppendingPath: "orders/"+currentOrder!)
        drinksListener.observe(FEventType.value, with: { snapshot in
            print(self.active)
            if(self.active){
            if snapshot?.value is NSNull {
                print("was null")
                self.clearBases()
                if(!self.receivedDone){
                    self.clearInterface()
                }
                
            } else {
                
                self.updateViews(snapshot!)
            }
            }
        })
    }
    }
    
    
    //#MARK: - Update UI Methods
    
    func updateViews(_ snapshot:FDataSnapshot) -> Void{

        if snapshot.value is NSNull {
            self.activity.stopAnimating()
            self.statusMessage.text = "Your drink is ready!"
            self.receivedDone = true
            self.thanksBig.isHidden = false;
        } else {
        
        if let value = (snapshot.value as AnyObject).object(forKey: "status") as? String{
        let drink = (snapshot.value as AnyObject).object(forKey: "product") as! String
        NSLog(value)
        //self.newDrink.enabled = false
        self.newDrinkBig.isHidden = true;
            self.thanksBig.isHidden = true;
            if(keyAlreadyExist(favourite)){
                self.favButton.isHidden = true
            }
        self.statusMessage.isHidden = false;
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
            self.thanksBig.isHidden = false;
      
        }
            }
        }


    }
    
    
    @IBAction func ThanksButtonPressed(){
        clearInterface()
        resetDone()
    }
    
    
    @IBAction func clearInterface(){
        self.statusMessage.isHidden = true;
        self.activity.stopAnimating()
        self.newDrinkBig.isHidden = false;
        
        if(keyAlreadyExist(favourite)){
            self.favButton.isHidden = false
        }
        
        self.receivedDone = false
        self.thanksBig.isHidden = true;
        
    }
    
    func resetDone(){
        drinksListener.removeAllObservers()
        UserDefaults.standard.removeObject(forKey: orderIDk)
        UserDefaults.standard.removeObject(forKey: notificationReceived)
    }
    
    func clearBases(){
        print("clearing bases")
        checkCalled = false;
        MainBase.removeAllObservers()
        statusListener.removeAllObservers()
        drinksListener.removeAllObservers()
        configListener.removeAllObservers()
        let removeer = MainBase.child(byAppendingPath: "orders/"+currentOrder!) as Firebase
        removeer.removeValue()
        removeer.removeAllObservers()
        UserDefaults.standard.removeObject(forKey: orderIDk)
        UserDefaults.standard.removeObject(forKey: notificationReceived)
    }
    

    
    //MARK: - addUser delegate methods
    func returnedUser() {
        initMain()
    }
    
}

