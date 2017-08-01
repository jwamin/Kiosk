//
//  AppDelegate.swift
//  Coffee
//
//  Created by Joss Manger on 23/12/2015.
 
//

import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
   
        if let resetSettings = NSUserDefaults.standardUserDefaults().objectForKey(resetSettingsKey) as? Bool{
            if (resetSettings == true){
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kUsernameKey)
                NSUserDefaults.standardUserDefaults().removeObjectForKey(favourite)
                NSUserDefaults.standardUserDefaults().removeObjectForKey(orderIDk)
                NSUserDefaults.standardUserDefaults().removeObjectForKey(halfShotEnabledKey)
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: resetSettingsKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        
        
        let action = UIMutableUserNotificationAction()
        action.identifier = "THANKS"
        action.title = "Thanks!"
        action.activationMode = UIUserNotificationActivationMode.Foreground
        action.authenticationRequired = true
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "CATEGORY"
        category.setActions([action], forContext: UIUserNotificationActionContext.Default)
        
//        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound,.Alert], categories: NSSet(object: category) as? Set<UIUserNotificationCategory>))
        
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound,.Alert], categories: nil));
        
        application.registerForRemoteNotifications()
        
        
        
        //endBackgroundTask()
        
        return true
    }

    func displayStatusChanged(ref:CFNotificationCenterRef){
        print("ref")
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("resigned active")
        //dobackground()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("entering background")
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //endBackgroundTask()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //endBackgroundTask()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //endBackgroundTask()
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print(notification)
    }

    //MARK - Background Task Methods for Local Notification
    
    var backgroundTask:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func registerBackgroundTask(){
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            [unowned self] in
            self.endBackgroundTask()
            })
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    

    func dobackground(){
        print("doing background process")
        print(keyAlreadyExist(notificationReceived))
        if(keyAlreadyExist(kUsernameKey) && !keyAlreadyExist(notificationReceived)){
            if let gotUniqueDrinkID = NSUserDefaults.standardUserDefaults().objectForKey(orderIDk) as? String{
                print("backgound process should run")
                registerBackgroundTask()
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    let get = Firebase(url: appURL).childByAppendingPath("orders/"+gotUniqueDrinkID)
                    get.observeEventType(FEventType.Value, withBlock: { snapshot in
                        print("in notification process")
                        if snapshot.value is NSNull {
                            print("was null - app delegate closure")
                        } else {
                            if let value = snapshot.value.objectForKey("status") as? String{
                                let drink = snapshot.value.objectForKey("product") as! String
                                
                                if(value=="done"){
                                    
                                    let notification = UILocalNotification()
                                    notification.fireDate = NSDate(timeIntervalSinceNow: 0.0)
                                    notification.timeZone = NSTimeZone.localTimeZone()
                                    notification.soundName = UILocalNotificationDefaultSoundName
                                    
                                    
                                    notification.alertTitle = "Collect from the Kiosk now"
                                    notification.alertBody = "Your \(drink) is ready!"
                                    
                                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                                    
                                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: notificationReceived)
                                    
                                    //get.removeAllObservers()
                                    
                                    self.endBackgroundTask()
                                    
                                }
                            }
                        }
                        
                        
                        
                    })
                    
                });
            }
            
        }
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("registered with token: \(deviceToken)")
        
        let cleaned = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        NSUserDefaults.standardUserDefaults().setObject(cleaned, forKey: "devicePushKey")
        
        print(cleaned)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("yeah, big error", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("remote notification received")
        print(userInfo)
    }
    
    
}

