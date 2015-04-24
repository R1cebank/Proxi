//
//  ProfileViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/23/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit

class ProfileViewController : UIViewController, UITextFieldDelegate, YALTabBarInteracting {
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    @IBOutlet weak var nickname: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nickname.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        nickname.text = NSUserDefaults.standardUserDefaults().stringForKey("handle")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func dismissKeyboard() {
        nickname.resignFirstResponder()
        
        println("dismissed keyboard")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    func extraLeftItemDidPressed() {
        println("ProfileViewController : Modifying")
        println("ProfileViewController : nickname : \(nickname.text)")
        NSUserDefaults.standardUserDefaults().setValue(nickname.text, forKey: "handle")
        appDelegate.mpcManager.handle = nickname.text
        appDelegate.mpcManager.idName[appDelegate.mpcManager.peer.displayName] = nickname.text
    }
}