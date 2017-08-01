//
//  closed.swift
//  Coffee
//
//  Created by Joss Manger on 24/12/2015.
 
//

import UIKit
import Firebase

class closed: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textArea: UITextView!
    var StatusSubscriber:Firebase!
    var text:String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resigned", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "becameActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        print("closed screen appeared")
        subscribeToStatus()
        textArea.text = ""
        if let gotText = text{
            textArea.text = gotText
            textArea.textAlignment = .Center
        }
        
    }
    
    func resigned(){
        print("closed screen resigned active")
        StatusSubscriber.removeAllObservers()
    }
    
    func becameActive(){
        print("closed screen returned from inactive")
        subscribeToStatus()
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("closed screen disappeared")
    }
    
    deinit{
        print("deinit closed screen")
    }
    
    func subscribeToStatus()->Void{
        StatusSubscriber = Firebase(url: appURL)
        StatusSubscriber.childByAppendingPath("config").observeEventType(FEventType.Value, withBlock: { snapshot in
            
            if snapshot.value is NSNull {
                print("error")
            } else {
                if let status = snapshot.value.objectForKey("status"){
                    let stat = status as! String
                    if (stat=="open"){
                        
                        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
                        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
                        
                        self.dismissViewControllerAnimated(true, completion: {
                        
                            
                        
                        })
                    }
                } else {
                    print("error")
                }
                
            }
            
        })
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
