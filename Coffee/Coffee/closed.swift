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
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(closed.resigned), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closed.becameActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        print("closed screen appeared")
        subscribeToStatus()
        textArea.text = ""
        if let gotText = text{
            textArea.text = gotText
            textArea.textAlignment = .center
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
    
    override func viewWillDisappear(_ animated: Bool) {
        print("closed screen disappeared")
    }
    
    deinit{
        print("deinit closed screen")
    }
    
    func subscribeToStatus()->Void{
        StatusSubscriber = Firebase(url: appURL)
        StatusSubscriber.child(byAppendingPath: "config").observe(FEventType.value, with: { snapshot in
            
            if snapshot?.value is NSNull {
                print("error")
            } else {
                if let status = (snapshot?.value as AnyObject).object(forKey: "status"){
                    let stat = status as! String
                    if (stat=="open"){
                        
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
                        
                        self.dismiss(animated: true, completion: {
                        
                            
                        
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
