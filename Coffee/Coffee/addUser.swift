//
//  addUser.swift
//  
//
//  Created by Joss Manger on 23/12/2015.
//
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


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
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddUser.keyboardShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddUser.keyboardHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //Submit New User Name Function
    @IBAction func submit(_ sender: AnyObject) {
       
        if let name = nameField.text{
            if (name.replacingOccurrences(of: " ", with: "") == ""){
            let alert = UIAlertController(title: "Alert", message: "Please write your name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(name, forKey: kUsernameKey)
                UserDefaults.standard.synchronize()
            
                self.dismiss(animated: true, completion: {
                    self.delegate?.returnedUser()
                })
            }
        }
        
    }
    
    // MARK: - Keyboard Methods for Phones <480pt h
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.nameField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
        
    }
    
    func keyboardShow(_ notification:Notification){
        let uidict = notification.userInfo! as NSDictionary

        let keyboardFrameBegin = uidict.value(forKey: UIKeyboardFrameBeginUserInfoKey)
        
        let keybaordRect:CGRect = ((keyboardFrameBegin! as AnyObject).cgRectValue as CGRect)
        
        print(keybaordRect.height)
        
        if(self.view.window?.frame.height<=480){
            animateView(true, height: keybaordRect.height)
        }
        
    }
    
    func keyboardHide(_ notification:Notification){
        let uidict = notification.userInfo! as NSDictionary
        
        let keyboardFrameBegin = uidict.value(forKey: UIKeyboardFrameBeginUserInfoKey)
        
        let keybaordRect:CGRect = ((keyboardFrameBegin! as AnyObject).cgRectValue as CGRect)
        
        print(keybaordRect.height)
        
        if(self.view.window?.frame.height<=480){
            animateView(false, height: keybaordRect.height)
        }
    }
    
    
    func animateView(_ up:Bool,height:CGFloat) -> Void{
        var animateBy:CGFloat = 0.0
        if(up){
            animateBy -= (height / 2)
        } else {
            animateBy += 8
        }
        self.topLayoutConstriant.constant = animateBy
        self.view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
            }, completion: { myBool in
            print("done")
        })
        
    }
    
    
  
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.destination)
    }
  

}
