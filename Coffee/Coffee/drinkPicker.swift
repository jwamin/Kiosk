//
//  drinkPicker.swift
//  Coffee
//
//  Created by Joss Manger on 23/12/2015.
//  Copyright Â© 2015  jossy. All rights reserved.
//

import UIKit

class drinkPicker: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //MARK: - Instance Variables and ViewController Methods
    
    //Interface Builder Outlets (@IBOutlet)
    @IBOutlet var blurview: UIVisualEffectView!
    @IBOutlet var syrupPicker: UIPickerView!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var drinkpickerview: UIPickerView!
    @IBOutlet var shots: UISegmentedControl!
    @IBOutlet var style: UISegmentedControl!
    @IBOutlet var milk: UISegmentedControl!
    @IBOutlet var syrupButton: UIButton!
    
    //Instance variables
    var selectedDrink:Dictionary<String,AnyObject>!
    var selectedSyrup = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drinkpickerview.delegate = self
        self.title = "My Drink"
        selectedDrink = drinks[0] as! Dictionary<String,AnyObject>
        // Do any additional setup after loading the view.
        
        var img:UIImage = UIImage(named: "fav")!;
        
        if(!keyAlreadyExist(favourite)){
            img = UIImage(named: "favEmpty")!;

        }        
        
        let favsButton = UIBarButtonItem(image: img, landscapeImagePhone: img, style: UIBarButtonItemStyle.Plain, target: self, action: "addEditFavourite:"); //(barButtonSystemItem: style, target: self, action: "addEditFavourite:")
        self.navigationItem.rightBarButtonItem = favsButton
        
        
    }
    
    override func viewWillAppear(animated: Bool) {

            let setting = NSUserDefaults.standardUserDefaults().boolForKey(halfShotEnabledKey)
            if (setting == false){
                shots.removeSegmentAtIndex(0, animated: false)
                
                shots.selectedSegmentIndex = UISegmentedControlNoSegment;
                shots.selectedSegmentIndex = 0;
            }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Create and return drink dictionary from selected options
    
    func createDrinkDictionary(isFavourite:Bool) -> NSDictionary{
        var dict:[String:AnyObject] = [:];
        
        dict["product"] = selectedDrink["name"] as? String
        
        
        let setting = NSUserDefaults.standardUserDefaults().boolForKey(halfShotEnabledKey)
        if (setting == false){
            dict["shots"] = String(shots.selectedSegmentIndex + 1)
        } else {
            dict["shots"] = String(shots.selectedSegmentIndex)
        }
        
        
        
        dict["style"] = styleArr[style.selectedSegmentIndex]
        dict["syrup"] = syrups[selectedSyrup] as? String
        dict["status"] = "pending"
        dict[favourite] = isFavourite
        
        return dict
    }
    
    //Return selected drink to postOrder method on main view controller (delegate methods)
    @IBAction func submit(sender: AnyObject) {
        
        let dict = createDrinkDictionary(false)
        
        let rvc = self.navigationController?.viewControllers[0] as? ViewController
        rvc?.postOrder(dict)
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    // MARK: - UI update methods
    
    func updateOptions() -> Void{
        if(selectedDrink["shots"] as? Bool == true){
            shots.enabled = true
            
            let setting = NSUserDefaults.standardUserDefaults().boolForKey(halfShotEnabledKey)
            if (setting == true){
                if(selectedDrink["half"] as? Bool == false){
                    shots.setEnabled(false, forSegmentAtIndex: 0)
                } else {
                    shots.setEnabled(true, forSegmentAtIndex: 0)
                }
            }
            
        } else {
            shots.enabled = false;
            shots.setEnabled(true, forSegmentAtIndex: 0)
        }
        
        if(selectedDrink["style"] as? Bool == true){
            style.enabled = true
        } else {
            style.enabled = false;
        }
        
        if(selectedDrink["type"] as? Bool == true){
            milk.enabled = true
        } else {
            milk.enabled = false;
        }
        
        if(selectedDrink["syrups"] as? Bool == true){
            syrupButton.enabled = true
            syrupButton.backgroundColor = UIColor.blackColor()
            
        } else {
            syrupButton.enabled = false;
            syrupButton.backgroundColor = UIColor.grayColor()
        }
        
        
        
    }
    
    /*
    // MARK: - Syrup picker view methods
    
    */
    
    @IBAction func pickSyrup(){
        blurview.layer.opacity = 0
        blurview.hidden = false;
        
        UIView.animateWithDuration(0.5, animations: {
            self.blurview.layer.opacity = 1;
        })
        
    }
    
    @IBAction func pickedSyrup(sender: UIButton) {
        selectedSyrup = syrupPicker.selectedRowInComponent(0)
        syrupButton.setTitle(syrups[selectedSyrup] as? String, forState: .Normal)
        
        UIView.animateWithDuration(0.5, animations: {
            self.blurview.layer.opacity = 0
            
            }, completion: {
                myBool in
                self.blurview.hidden = false;
        })
        
    }
    
    /*
    // MARK: - UIPickerView delegate methods
    
    */
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 0){
            return drinks[row]["name"] as? String
        }
        if(pickerView.tag == 1){
            return syrups[row] as? String
        }
        return "option \(row)"
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 0){
            return drinks.count
        }
        if(pickerView.tag == 1){
            return syrups.count
        }
        return 0
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //call updateOptions() on row selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 0){
            selectedDrink = drinks[row] as! Dictionary<String, AnyObject>
            updateOptions()
        }
        
    }
    
    //MARK: - Favourites functionality methods
    
    //Create favourite from selected options
    func addEditFavourite(sender:AnyObject?){
        
        if let sentSender = sender{
            print(sentSender)
        }
        
        let drink = selectedDrink["name"] as! String
        let alertVC = UIAlertController(title: "My Favourite", message: "", preferredStyle: .Alert)
        
        if(keyAlreadyExist(favourite)){
            alertVC.message = "You have already created a favourite. Would you like to change it with this \(drink)?"
        } else {
            alertVC.message="Set this \(drink) as your new favourite?"
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: commitFavourite)
        let noAction = UIAlertAction(title: "Nope", style: UIAlertActionStyle.Cancel, handler: nil)
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
        
    }
    
    
    //Save favourite to NSUserDefaults
    func commitFavourite(action:UIAlertAction?) -> Void{
        if let recievedAction = action{
            print(recievedAction)
        } else {
            print("no action received")
        }
        
        let favouriteDict = createDrinkDictionary(true)
        
        NSUserDefaults.standardUserDefaults().setObject(favouriteDict, forKey: favourite)
        
        let img:UIImage = UIImage(named: "fav")!;
        let favsButton = UIBarButtonItem(image: img, landscapeImagePhone: img, style: UIBarButtonItemStyle.Plain, target: self, action: "addEditFavourite:");
        self.navigationItem.rightBarButtonItem = favsButton
        
        let rootVC = self.navigationController?.viewControllers.first as! ViewController
        
        rootVC.favButton.hidden = false
        
    }
    
    
}