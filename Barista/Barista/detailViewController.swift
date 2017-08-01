//
//  detailViewController.swift
//  Barista
//
//  Created by Joss Manger on 29/01/2016.
 
//

import UIKit

class detailViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var shotSwitch: UISwitch!
    @IBOutlet var halfShotSwitch: UISwitch!

    @IBOutlet var styleSwitch: UISwitch!
    @IBOutlet var syrupSwitch: UISwitch!
    @IBOutlet var milkSwitch: UISwitch!
    @IBOutlet var nameField: UITextField!

    @IBOutlet var drinkDeleteButton: UIButton!
    
    var thisDrink:NSDictionary? = nil
    var selectedIndex:Int? = nil
    var newDrink = false;
    
    var delegate:drinkDetailDelegate? = nil
    @IBOutlet var detailTitle: UINavigationItem!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        nameField.delegate = self
        
    }
    
    deinit{
        print("detail view deinitialised")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        print(thisDrink)
        
        if(!newDrink){
            
            detailTitle.title = thisDrink!["name"] as? String
            nameField.text = thisDrink!["name"] as? String
            self.shotSwitch.on = thisDrink!["shots"] as! Bool
            self.milkSwitch.on = thisDrink!["type"] as! Bool
            self.styleSwitch.on = thisDrink!["style"] as! Bool
            if let half = thisDrink!["half"] as? Bool{
                self.halfShotSwitch.on = half
            } else {
                self.halfShotSwitch.on = false;
            }
            
            self.syrupSwitch.on = thisDrink!["syrups"] as! Bool
        } else {
            drinkDeleteButton.enabled = false;
        }

        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        detailTitle.title = nameField.text
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        detailTitle.title = nameField.text
    }
    
    @IBAction func deleteDrink() {
        
        delegate?.requestDelete(selectedIndex!)
        
    }
    
    @IBAction func commitSubmit() {
       print("commit submit called")
        
        var drink = Dictionary<String,AnyObject>()
        
        drink["name"] = nameField.text
        drink["shots"] = shotSwitch.on
        drink["type"] = milkSwitch.on
        drink["style"] = styleSwitch.on
        drink["half"] = halfShotSwitch.on
        drink["syrups"] = syrupSwitch.on
        delegate?.drinkSubmit(drink,sender: self)
        
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
