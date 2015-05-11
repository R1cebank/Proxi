//
//  IntroViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 5/9/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit
import AMPopTip

class IntroViewController: UIViewController, BWWalkthroughPage, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textBox: UITextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textBox.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    // MARK: BWWalkThroughPage protocol
    
    func walkthroughDidScroll(position: CGFloat, offset: CGFloat) {
        var tr = CATransform3DIdentity
        tr.m34 = -1/500.0
        
        titleLabel?.layer.transform = CATransform3DRotate(tr, CGFloat(M_PI) * (1.0 - offset), 1, 1, 1)
        textLabel?.layer.transform = CATransform3DRotate(tr, CGFloat(M_PI) * (1.0 - offset), 1, 1, 1)
        textBox?.layer.transform = CATransform3DRotate(tr, CGFloat(M_PI) * (1.0 - offset), 1, 1, 1)
        
        var tmpOffset = offset
        if(tmpOffset > 1.0){
            tmpOffset = 1.0 + (1.0 - tmpOffset)
        }
        imageView?.layer.transform = CATransform3DTranslate(tr, 0 , (1.0 - tmpOffset) * 200, 0)
    }
    @IBAction func editingEnded(sender: AnyObject) {
        println("ProfileViewContoller : editing ended")
        println("ProfileViewController : Modifying")
        println("ProfileViewController : nickname : \(textBox.text)")
        NSUserDefaults.standardUserDefaults().setValue(textBox.text, forKey: "handle")
        appDelegate.mpcManager.newHandle(textBox.text)
    }
    @IBAction func buttonTouched(sender: AnyObject) {
        var tip = AMPopTip()
        tip.popoverColor = UIColor(red: 72/255, green: 211/255, blue: 178/255, alpha: 1)
        tip.showText("edit your name here and touch anywhere to save", direction: AMPopTipDirection.Down, maxWidth: 200, inView: self.view, fromFrame: textBox.frame)
        println("touched")
    }
    override func viewWillAppear(animated: Bool) {
        //textBox.text = NSUserDefaults.standardUserDefaults().stringForKey("handle")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func dismissKeyboard() {
        textBox.resignFirstResponder()
        
        println("dismissed keyboard")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
}
