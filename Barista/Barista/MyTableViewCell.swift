//
//  MyTableViewCell.swift
//  TABLE
//
//  Created by Joss Manger on 27/12/2015.
//  Copyright © 2015 Joss Manger. All rights reserved.
//

import UIKit

@objc protocol tableCellControlDelegate{
    
    func cellButtonPressed(cell: MyTableViewCell)
    optional func cellCompletedPressed(cell: MyTableViewCell)
    optional func removeCell(cell: MyTableViewCell)
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
    
    @IBAction func start(sender: AnyObject) {
        print(button.titleLabel?.text)
        animateCell();
        button.setTitle("Updating...", forState: .Normal)
        print(button.titleLabel?.text)
        delegate?.cellButtonPressed(self)
        
    }
    
    func statusRearrange(){
        print("rearranging on cell")
        self.animating.startAnimating()
        self.animating.hidden = false
        self.button.hidden = true
        self.animating.layer.opacity = 1
        self.doneButton.hidden = false;
        self.doneButton.layer.opacity = 1
        self.doneButton.addTarget(self, action: "donebuttonpressed:", forControlEvents: .TouchUpInside)
    }
    
    func animateCell(){
        self.doneButton.addTarget(self, action: "donebuttonpressed:", forControlEvents: .TouchUpInside)
    }
    
    func donebuttonpressed(thingy:AnyObject){
        doneButton.setTitle("Updating...", forState: .Normal)
        self.delegate?.cellCompletedPressed!(self)
    }
    
    func started(){
        print(button.titleLabel?.text)
        animating.startAnimating()
        doneButton.hidden = false
        button.layer.opacity = 0
        animating.layer.opacity = 1
        doneButton.layer.opacity = 1
        print(button.titleLabel?.text)
    }
    
    func animateStart(backwards:Bool?){
        animating.startAnimating()
        doneButton.hidden = false
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
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: {
                self.button.layer.opacity = 0
                self.button.layer.position.x = (self.button.layer.position.x - 20)
            })
            
            
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
                self.animating.layer.position.x = self.animating.layer.position.x + 20
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
                self.animating.layer.opacity = 1
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0.2, animations: {
                self.doneButton.layer.opacity = 1
                self.doneButton.layer.position.x = (self.button.layer.position.x - 20)
            })
            
        }
        
        //var options:UIViewKeyframeAnimationOptions = .Autoreverse
        
        UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations:animations, completion: {mybool in
                print(mybool)
        })

    }
    
    func animateEnd(){
        UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations:{
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3, animations: {
                self.doneButton.layer.opacity = 0
                self.doneButton.layer.position.x = (self.button.layer.position.x + 20)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: {
                self.crazylabel.layer.position.x = self.crazylabel.layer.position.x + 20
                self.crazylabel.layer.opacity = 0
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
                self.animating.layer.opacity = 0
            })
            
            }, completion: {mybool in
                
                self.crazylabel.text = "Awesome!"
                
                UIView.animateKeyframesWithDuration(0.2, delay: 0.0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: {
                    
                    UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
                        self.crazylabel.layer.position.x = self.crazylabel.layer.position.x - 20
                        self.crazylabel.layer.opacity = 1
                    })
                    
                    }, completion: {mybool in
                        self.animating.stopAnimating()
                        self.animating.hidden = true
                        self.delegate?.removeCell?(self)
                })
                
                
        })

    }
    
    override func animationDidStart(anim: CAAnimation) {
        print("animtation started ",anim)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        print("animtation stopped ",anim)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
