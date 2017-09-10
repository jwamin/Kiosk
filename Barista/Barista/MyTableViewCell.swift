//
//  MyTableViewCell.swift
//  TABLE
//
//  Created by Joss Manger on 27/12/2015.
//  Copyright © 2015 Joss Manger. All rights reserved.
//

import UIKit

@objc protocol tableCellControlDelegate{
    
    func cellButtonPressed(_ cell: MyTableViewCell)
    @objc optional func cellCompletedPressed(_ cell: MyTableViewCell)
    @objc optional func removeCell(_ cell: MyTableViewCell)
}


class MyTableViewCell: UITableViewCell {

    @IBOutlet var button: UIButton!
    @IBOutlet var crazylabel: UILabel!
    @IBOutlet var animating: UIActivityIndicatorView!
    
    @IBOutlet var doneButton: UIButton!
    
    var cellInProgress:Bool? = nil
    
    // weak delegate allows for deinit of cell ?
    weak var delegate:tableCellControlDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
        
        NSLog("Aha! Awake from NIB")
        print(cellInProgress)
        if let cellstatus = cellInProgress{
            if(cellstatus == true){
               statusRearrange()
            }
        }
    }

    deinit{
        //NSLog("deinit cell");
    }

    override func didMoveToSuperview() {
        animating.layer.opacity = 0
        doneButton.layer.opacity = 0

    }
    
    @IBAction func start(_ sender: AnyObject) {
        print(button.titleLabel?.text)
        animateCell();
        button.setTitle("Updating...", for: UIControlState())
        print(button.titleLabel?.text)
        delegate?.cellButtonPressed(self)
        
    }
    
    func statusRearrange(){
        print("rearranging on cell")
        self.animating.startAnimating()
        self.animating.isHidden = false
        self.button.isHidden = true
        self.animating.layer.opacity = 1
        self.doneButton.isHidden = false;
        self.doneButton.layer.opacity = 1
        self.doneButton.addTarget(self, action: #selector(MyTableViewCell.donebuttonpressed(_:)), for: .touchUpInside)
    }
    
    func animateCell(){
        self.doneButton.addTarget(self, action: #selector(MyTableViewCell.donebuttonpressed(_:)), for: .touchUpInside)
    }
    
    func donebuttonpressed(_ thingy:AnyObject){
        doneButton.setTitle("Updating...", for: UIControlState())
        self.delegate?.cellCompletedPressed!(self)
    }
    
    func started(){
        print(button.titleLabel?.text)
        animating.startAnimating()
        doneButton.isHidden = false
        button.layer.opacity = 0
        animating.layer.opacity = 1
        doneButton.layer.opacity = 1
        print(button.titleLabel?.text)
    }
    
    func animateStart(_ backwards:Bool?){
        animating.startAnimating()
        doneButton.isHidden = false
        // works, symiltaneous animation
        /*
        UIView.animateWithDuration(1.0, animations: {
        self.button.layer.opacity = 0
        self.button.layer.position.x = (self.button.layer.position.x - 20)
        self.animating.layer.opacity = 1
        self.animating.layer.position.x = self.animating.layer.position.x + 20
        })
        */
        
        //Does not work, keyframe animation
        self.animating.layer.position.x = self.animating.layer.position.x - 20
        self.doneButton.layer.position.x = (self.button.layer.position.x - 20)
        
        let animations = {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                self.button.layer.opacity = 0
                self.button.layer.position.x = (self.button.layer.position.x - 20)
            })
            
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.animating.layer.position.x = self.animating.layer.position.x + 20
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.animating.layer.opacity = 1
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2, animations: {
                self.doneButton.layer.opacity = 1
                self.doneButton.layer.position.x = (self.button.layer.position.x - 20)
            })
            
        }
        
        //var options:UIViewKeyframeAnimationOptions = .Autoreverse
        
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations:animations, completion: {mybool in
                print(mybool)
        })

    }
    
    func animateEnd(){
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations:{
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3, animations: {
                self.doneButton.layer.opacity = 0
                self.doneButton.layer.position.x = (self.button.layer.position.x + 20)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                self.crazylabel.layer.position.x = self.crazylabel.layer.position.x + 20
                self.crazylabel.layer.opacity = 0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.animating.layer.opacity = 0
            })
            
            }, completion: {mybool in
                
                self.crazylabel.text = "Awesome!"
                
                UIView.animateKeyframes(withDuration: 0.2, delay: 0.0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                        self.crazylabel.layer.position.x = self.crazylabel.layer.position.x - 20
                        self.crazylabel.layer.opacity = 1
                    })
                    
                    }, completion: {mybool in
                        self.animating.stopAnimating()
                        self.animating.isHidden = true
                        self.delegate?.removeCell?(self)
                })
                
                
        })

    }
    
    func animationDidStart(_ anim: CAAnimation) {
        print("animtation started ",anim)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("animtation stopped ",anim)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
