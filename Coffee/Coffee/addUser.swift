//
//  addUser.swift
//  
//
//  Created by Joss Manger on 23/12/2015.
//
//

import UIKit

//MARK: New User Protocol
protocol newuserProtocolDelegate{
    func returnedUser()
}

//MARK: AddUser Class Definition
class AddUser: UIViewController, UITextFieldDelegate {

    
    // MARK: - IBOutlet Components
    @IBOutlet var topLayoutConstriant: NSLayoutConstraint!
    @IBOutlet var nameField: UITextField!
    
    // optional delegate variable
    var delegate:newuserProtocolDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameField.delegate = self
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardDidHideNotification, object: nil)
    }

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //Submit New User Name Function
    @IBAction func submit(sender: AnyObject) {
       
        if let name = nameField.text{
            if (name.stringByReplacingOccurrencesOfString(" ", withString: "") == ""){
            let alert = UIAlertController(title: "Alert", message: "Please write your name", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(name, forKey: kUsernameKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            
                self.dismissViewControllerAnimated(true, completion: {
                    self.delegate?.returnedUser()
                })
            }
        }
        
    }
    
    // MARK: - Keyboard Methods for Phones <480pt h
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.nameField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {

        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
        
    }
    
    func keyboardShow(notification:NSNotification){
        let uidict = notification.userInfo! as NSDictionary

        let keyboardFrameBegin = uidict.valueForKey(UIKeyboardFrameBeginUserInfoKey)
        
        let keybaordRect:CGRect = (keyboardFrameBegin!.CGRectValue as CGRect)
        
        print(keybaordRect.height)
        
        if(self.view.window?.frame.height<=480){
            animateView(true, height: keybaordRect.height)
        }
        
    }
    
    func keyboardHide(notification:NSNotification){
        let uidict = notification.userInfo! as NSDictionary
        
        let keyboardFrameBegin = uidict.valueForKey(UIKeyboardFrameBeginUserInfoKey)
        
        let keybaordRect:CGRect = (keyboardFrameBegin!.CGRectValue as CGRect)
        
        print(keybaordRect.height)
        
        if(self.view.window?.frame.height<=480){
            animateView(false, height: keybaordRect.height)
        }
    }
    
    
    func animateView(up:Bool,height:CGFloat) -> Void{
        var animateBy:CGFloat = 0.0
        if(up){
            animateBy -= (height / 2)
        } else {
            animateBy += 8
        }
        self.topLayoutConstriant.constant = animateBy
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
            }, completion: { myBool in
            print("done")
        })
        
    }
    
    
  
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.destinationViewController)
    }
  

}
