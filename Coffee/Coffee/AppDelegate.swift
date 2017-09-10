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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
   
        if let resetSettings = UserDefaults.standard.object(forKey: resetSettingsKey) as? Bool{
            if (resetSettings == true){
                UserDefaults.standard.removeObject(forKey: kUsernameKey)
                UserDefaults.standard.removeObject(forKey: favourite)
                UserDefaults.standard.removeObject(forKey: orderIDk)
                UserDefaults.standard.removeObject(forKey: halfShotEnabledKey)
                UserDefaults.standard.set(false, forKey: resetSettingsKey)
                UserDefaults.standard.synchronize()
            }
        }
        
        
        let action = UIMutableUserNotificationAction()
        action.identifier = "THANKS"
        action.title = "Thanks!"
        action.activationMode = UIUserNotificationActivationMode.foreground
        action.isAuthenticationRequired = true
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "CATEGORY"
        category.setActions([action], for: UIUserNotificationActionContext.default)
        
//        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound,.Alert], categories: NSSet(object: category) as? Set<UIUserNotificationCategory>))
        
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound,.alert], categories: nil));
        
        application.registerForRemoteNotifications()
        
        
        
        //endBackgroundTask()
        
        return true
    }

    func displayStatusChanged(_ ref:CFNotificationCenter){
        print("ref")
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("resigned active")
        //dobackground()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("entering background")
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //endBackgroundTask()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //endBackgroundTask()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //endBackgroundTask()
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print(notification)
    }

    //MARK - Background Task Methods for Local Notification
    
    var backgroundTask:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func registerBackgroundTask(){
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            [unowned self] in
            self.endBackgroundTask()
            })
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    

    func dobackground(){
        print("doing background process")
        print(keyAlreadyExist(notificationReceived))
        if(keyAlreadyExist(kUsernameKey) && !keyAlreadyExist(notificationReceived)){
            if let gotUniqueDrinkID = UserDefaults.standard.object(forKey: orderIDk) as? String{
                print("backgound process should run")
                registerBackgroundTask()
                
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                    
                    let get = Firebase(url: appURL).child(byAppendingPath: "orders/"+gotUniqueDrinkID)
                    get?.observe(FEventType.value, with: { snapshot in
                        print("in notification process")
                        if snapshot?.value is NSNull {
                            print("was null - app delegate closure")
                        } else {
                            if let value = (snapshot?.value as AnyObject).object(forKey: "status") as? String{
                                let drink = (snapshot?.value as AnyObject).object(forKey: "product") as! String
                                
                                if(value=="done"){
                                    
                                    let notification = UILocalNotification()
                                    notification.fireDate = Date(timeIntervalSinceNow: 0.0)
                                    notification.timeZone = TimeZone.autoupdatingCurrent
                                    notification.soundName = UILocalNotificationDefaultSoundName
                                    
                                    
                                    notification.alertTitle = "Collect from the Kiosk now"
                                    notification.alertBody = "Your \(drink) is ready!"
                                    
                                    UIApplication.shared.scheduleLocalNotification(notification)
                                    
                                    UserDefaults.standard.set(true, forKey: notificationReceived)
                                    
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
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("registered with token: \(deviceToken)")
        
        let cleaned = deviceToken.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>")).replacingOccurrences(of: " ", with: "")
        
        UserDefaults.standard.set(cleaned, forKey: "devicePushKey")
        
        print(cleaned)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("yeah, big error", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("remote notification received")
        print(userInfo)
    }
    
    
}

