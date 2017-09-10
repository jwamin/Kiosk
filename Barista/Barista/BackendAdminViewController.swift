//
//  BackendAdminViewController.swift
//  Barista
//
//  Created by Joss Manger on 29/01/2016.
 
//

import UIKit
import Firebase

class BackendAdminViewController: UIViewController, UITableViewDelegate, adminModelDelegate, drinkDetailDelegate {
    @IBOutlet var drinks: UITableView!
    
    let model:adminModel! = adminModel()
    var selectedIndex:IndexPath? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        drinks.dataSource = model
        model.delegate = self
        
       //deleteAllDrinks()
        
        //drinks.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        selectedIndex = indexPath
        let vc = UIStoryboard(name: "AdminStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "detail") as! detailViewController
        
        vc.delegate = self
        vc.thisDrink = model.drinksSettings[(selectedIndex?.row)!]
        vc.selectedIndex = (selectedIndex?.row)!
        splitViewController?.showDetailViewController(vc, sender: nil)
        
    }
    

    
    @IBAction func newDrink(_ sender: AnyObject) {
    
        let vc = UIStoryboard(name: "AdminStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "detail") as! detailViewController
        
        vc.delegate = self
        vc.thisDrink = [:]
        vc.newDrink = true;
        vc.selectedIndex = model.drinksSettings.count
        splitViewController?.showDetailViewController(vc, sender: nil)
        
    }
    @IBAction func refresh(_ sender: AnyObject) {
        model.getDrinksSettings()
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    deinit{
        print("master view deinitialised")
    }
    
    func drinkSubmit(_ drink:Dictionary<String,AnyObject>,sender:detailViewController){
        let updateBase = Firebase(url: appURL)
        updateBase?.authUser(authEmail, password: authPasswd) {
            error, authData in
            if error != nil {
                let alery = UIAlertController(title: "Error", message: "There was a problem posting your drink", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alery.addAction(action)
                self.present(alery, animated: true, completion: nil)
            } else {
                let postRef = updateBase?.child(byAppendingPath: "config/drinks")
                let post = postRef?.childByAutoId()
                post?.setValue(drink)
                let vc = UIStoryboard(name: "AdminStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "placeholder")
                
                
                self.model.getDrinksSettings()
                
                self.splitViewController?.showDetailViewController(vc, sender: nil)
            }

    
        }
    }
    
    //remove drink at index, update all drinks.
    
    //OR
    
    //unique ids for drinks, remove unique id
    
    //AND
    
    //Reorder using table view controller, index stored as k:v on drink
    
    func drinkDelete(_ index:String){
            let updateBase = Firebase(url: appURL)
            updateBase?.authUser(authEmail, password: authPasswd) {
                error, authData in
                if error != nil {
                    let alery = UIAlertController(title: "Error", message: "There was a problem removing your drink", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alery.addAction(action)
                    self.present(alery, animated: true, completion: nil)
                    self.model.getDrinksSettings()
                } else {
                    let postRef = updateBase?.child(byAppendingPath: "config/drinks/\(index)")
                    postRef?.removeValue(completionBlock: {
                        (err,fb) in
                      
                        let vc = UIStoryboard(name: "AdminStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "placeholder")
                        
                        
                        self.model.getDrinksSettings()
                        
                        self.splitViewController?.showDetailViewController(vc, sender: nil)
                        
                    })
                
            }
    }
    }
    
    
    func deleteAllDrinks(){
        let updateBase = Firebase(url: appURL)
        updateBase?.authUser(authEmail, password: authPasswd) {
            error, authData in
            if error != nil {
                let alery = UIAlertController(title: "Error", message: "There was a problem clearing drinks", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alery.addAction(action)
                self.present(alery, animated: true, completion: nil)
                self.model.getDrinksSettings()
            } else {
                let postRef = updateBase?.child(byAppendingPath: "config/drinks")
                postRef?.removeValue(completionBlock: {
                    (err,fb) in
                    
                    let vc = UIStoryboard(name: "AdminStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "placeholder")
                    
                    
                    self.model.getDrinksSettings()
                    
                    self.splitViewController?.showDetailViewController(vc, sender: nil)
                    
                })
                
            }
        }
    }
    
    func requestDelete(_ selectedIndex: Int) {
        let backendKey = model.drinksSettings[selectedIndex]["uniqueKey"] as! String
        print(backendKey)
        model.delegate?.drinkDelete(backendKey)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func successfulRequest() {
        drinks.reloadData()
    }
    
    
    
}

protocol drinkDetailDelegate {
    func drinkSubmit(_ drink:Dictionary<String,AnyObject>,sender:detailViewController)
    func requestDelete(_ selectedIndex:Int)
}

protocol adminModelDelegate {
    func successfulRequest()
    func drinkDelete(_ index:String)
}

class adminModel : NSObject, UITableViewDataSource{

    var drinksConfig:Firebase! = nil
    var drinksSettings:Array<NSDictionary> = []
    
    var delegate:adminModelDelegate? = nil
    
    override init(){
        super.init()
        getDrinksSettings()
    }
    
    deinit{
            print("model deinitialised")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "drinksCell")! as UITableViewCell
        print(drinksSettings[indexPath.row])
        cell.textLabel?.text = drinksSettings[indexPath.row]["name"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            let backendKey = drinksSettings[indexPath.row]["uniqueKey"] as! String
            print(backendKey)
            drinksSettings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            delegate?.drinkDelete(backendKey)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinksSettings.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func getDrinksSettings(){
        drinksConfig = Firebase(url: appURL).child(byAppendingPath: "config")
        drinksConfig.observeSingleEvent(of: FEventType.value, with: { snapshot in
            
            if snapshot?.value is NSNull {
                print("error")
            } else {
                print("called")
                
                var drinks:[NSDictionary] = [];
                //var drinkIndex = 0;
                if let drinkDictionary = (snapshot?.value as AnyObject).object(forKey: "drinks") as? Dictionary<String,Dictionary<String,AnyObject>>{
                    for (key,value) in drinkDictionary{
                        var modvlaue = value
                        modvlaue["uniqueKey"] = key as AnyObject
                        drinks.append(modvlaue as NSDictionary)
                    }

                } else {
                    print("type error")
                }
                
//
//                print(drinks)
                
                
                self.drinksSettings = drinks
                self.delegate?.successfulRequest()
            }
            
        })
    }
    
    @IBAction func commitSubmit(_ segue:UIStoryboardSegue) {
        print("commit submit")
       
        
    }
    
}
