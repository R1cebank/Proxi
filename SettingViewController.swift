//
//  SettingViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/20/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit
import GBFlatButton
import SIAlertView

class SettingViewController : UIViewController {
    
    @IBOutlet weak var setVisible: UISwitch!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBAction func resetAll(sender: AnyObject) {
        let alertView = SIAlertView(title: "Reset all data?", andMessage: "This will clear all of your recent peers and all chat logs. Are you sure?")
        alertView.addButtonWithTitle("Yes", type: SIAlertViewButtonType.Default) {
            (alertView) -> Void in
            println("Clearing data")
            self.appDelegate.mpcManager.reset()
            self.appDelegate.chatManager.reset()
            self.appDelegate.messageQueue.reset()
            self.appDelegate.reset()
            let alertView2 = SIAlertView(title: "Reset complete", andMessage: "The application will now exit") as SIAlertView
            alertView2.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default) {
                (alertView2) -> Void in
                self.appDelegate.applicationWillTerminate(UIApplication.sharedApplication())
                exit(0)
                
            }
            alertView2.show()
        }
        alertView.addButtonWithTitle("No", type: SIAlertViewButtonType.Cancel) {
            (alertView) -> Void in
            println("Dismiss reset")
        }
        
        alertView.show()
    }
    
    
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