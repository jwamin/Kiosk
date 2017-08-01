//
//  AppDelegate.swift
//  Barista
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
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound,.Alert], categories: nil))
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        dobackground()
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        
  
        
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        endBackgroundTask()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        //
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print(notification)
    }
    
    
    //MARK - Background
    
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
        NSLog("Background task started.")

                registerBackgroundTask()
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    // Do the work associated with the task, preferably in chunks.
                    
                    let get = Firebase(url: appURL).childByAppendingPath("orders")
                    get.observeEventType(FEventType.ChildAdded, withBlock: { snapshot in
                        
                        if snapshot.value is NSNull {
                            print("was null")
                        } else {
                            let key = snapshot.key as String
                            if(self.notInList(key)){
                                
                                notifiedList.append(key)
                            
                            if let value = snapshot.value.objectForKey("status") as? String{
                                let drink = snapshot.value.objectForKey("product") as! String
                                let person = snapshot.value.objectForKey("name") as! String
                                if(value=="pending"){
                                    
                                    let notification = UILocalNotification()
                                    notification.fireDate = NSDate(timeIntervalSinceNow: 0.0)
                                    notification.timeZone = NSTimeZone.localTimeZone()
                                    notification.soundName = UILocalNotificationDefaultSoundName
                                    
                                    
                                    notification.alertTitle = "Drink ordered"
                                    notification.alertBody = "\(drink) for \(person)"
                                    
                                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                                
                                    
                                    
                                }
                                }
                            }
                        }
                        
                        
                        
                    })
                    
                });
            
            
        }
    
    func notInList(keyToTest:String)->Bool{
        
        for key in notifiedList{
            if (key == keyToTest){
                print("match with \(key)")
                return false
            }
        }
        
        return true
    }
    
    
}

