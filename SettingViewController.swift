//
//  SettingViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/20/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit

class SettingViewController : UIViewController {
    
    @IBOutlet weak var setVisible: UISwitch!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBAction func setVisibleChanged(sender: UISwitch) {
        if(sender.on) {
            appDelegate.mpcManager.startAdvertising()
        } else {
            appDelegate.mpcManager.stopAdvertising()
        }
        NSUserDefaults.standardUserDefaults().setBool(setVisible.on, forKey: "isVisible")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        println("IsVisible status: \(appDelegate.mpcManager.isVisible)")
        setVisible.setOn(appDelegate.mpcManager.isVisible, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}