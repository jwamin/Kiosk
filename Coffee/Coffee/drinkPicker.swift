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
        
        let favsButton = UIBarButtonItem(image: img, landscapeImagePhone: img, style: UIBarButtonItemStyle.plain, target: self, action: #selector(drinkPicker.addEditFavourite(_:))); //(barButtonSystemItem: style, target: self, action: "addEditFavourite:")
        self.navigationItem.rightBarButtonItem = favsButton
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

            let setting = UserDefaults.standard.bool(forKey: halfShotEnabledKey)
            if (setting == false){
                shots.removeSegment(at: 0, animated: false)
                
                shots.selectedSegmentIndex = UISegmentedControlNoSegment;
                shots.selectedSegmentIndex = 0;
            }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Create and return drink dictionary from selected options
    
    func createDrinkDictionary(_ isFavourite:Bool) -> NSDictionary{
        var dict:[String:AnyObject] = [:];
        
        dict["product"] = selectedDrink["name"] as? String as AnyObject
        
        
        let setting = UserDefaults.standard.bool(forKey: halfShotEnabledKey)
        if (setting == false){
            dict["shots"] = String(shots.selectedSegmentIndex + 1) as AnyObject
        } else {
            dict["shots"] = String(shots.selectedSegmentIndex) as AnyObject
        }
        
        
        
        dict["style"] = styleArr[style.selectedSegmentIndex] as AnyObject
        dict["syrup"] = syrups[selectedSyrup] as? String as AnyObject
        dict["status"] = "pending" as AnyObject
        dict[favourite] = isFavourite as AnyObject
        
        return dict as NSDictionary
    }
    
    //Return selected drink to postOrder method on main view controller (delegate methods)
    @IBAction func submit(_ sender: AnyObject) {
        
        let dict = createDrinkDictionary(false)
        
        let rvc = self.navigationController?.viewControllers[0] as? ViewController
        rvc?.postOrder(dict)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: - UI update methods
    
    func updateOptions() -> Void{
        if(selectedDrink["shots"] as? Bool == true){
            shots.isEnabled = true
            
            let setting = UserDefaults.standard.bool(forKey: halfShotEnabledKey)
            if (setting == true){
                if(selectedDrink["half"] as? Bool == false){
                    shots.setEnabled(false, forSegmentAt: 0)
                } else {
                    shots.setEnabled(true, forSegmentAt: 0)
                }
            }
            
        } else {
            shots.isEnabled = false;
            shots.setEnabled(true, forSegmentAt: 0)
        }
        
        if(selectedDrink["style"] as? Bool == true){
            style.isEnabled = true
        } else {
            style.isEnabled = false;
        }
        
        if(selectedDrink["type"] as? Bool == true){
            milk.isEnabled = true
        } else {
            milk.isEnabled = false;
        }
        
        if(selectedDrink["syrups"] as? Bool == true){
            syrupButton.isEnabled = true
            syrupButton.backgroundColor = UIColor.black
            
        } else {
            syrupButton.isEnabled = false;
            syrupButton.backgroundColor = UIColor.gray
        }
        
        
        
    }
    
    /*
    // MARK: - Syrup picker view methods
    
    */
    
    @IBAction func pickSyrup(){
        blurview.layer.opacity = 0
        blurview.isHidden = false;
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blurview.layer.opacity = 1;
        })
        
    }
    
    @IBAction func pickedSyrup(_ sender: UIButton) {
        selectedSyrup = syrupPicker.selectedRow(inComponent: 0)
        syrupButton.setTitle(syrups[selectedSyrup] as? String, for: UIControlState())
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blurview.layer.opacity = 0
            
            }, completion: {
                myBool in
                self.blurview.isHidden = false;
        })
        
    }
    
    /*
    // MARK: - UIPickerView delegate methods
    
    */
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 0){
            return drinks[row]["name"] as? String
        }
        if(pickerView.tag == 1){
            return syrups[row] as? String
        }
        return "option \(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 0){
            return drinks.count
        }
        if(pickerView.tag == 1){
            return syrups.count
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //call updateOptions() on row selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 0){
            selectedDrink = drinks[row] as! Dictionary<String, AnyObject>
            updateOptions()
        }
        
    }
    
    //MARK: - Favourites functionality methods
    
    //Create favourite from selected options
    func addEditFavourite(_ sender:AnyObject?){
        
        if let sentSender = sender{
            print(sentSender)
        }
        
        let drink = selectedDrink["name"] as! String
        let alertVC = UIAlertController(title: "My Favourite", message: "", preferredStyle: .alert)
        
        if(keyAlreadyExist(favourite)){
            alertVC.message = "You have already created a favourite. Would you like to change it with this \(drink)?"
        } else {
            alertVC.message="Set this \(drink) as your new favourite?"
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: commitFavourite)
        let noAction = UIAlertAction(title: "Nope", style: UIAlertActionStyle.cancel, handler: nil)
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    
    //Save favourite to NSUserDefaults
    func commitFavourite(_ action:UIAlertAction?) -> Void{
        if let recievedAction = action{
            print(recievedAction)
        } else {
            print("no action received")
        }
        
        let favouriteDict = createDrinkDictionary(true)
        
        UserDefaults.standard.set(favouriteDict, forKey: favourite)
        
        let img:UIImage = UIImage(named: "fav")!;
        let favsButton = UIBarButtonItem(image: img, landscapeImagePhone: img, style: UIBarButtonItemStyle.plain, target: self, action: #selector(drinkPicker.addEditFavourite(_:)));
        self.navigationItem.rightBarButtonItem = favsButton
        
        let rootVC = self.navigationController?.viewControllers.first as! ViewController
        
        rootVC.favButton.isHidden = false
        
    }
    
    
}
