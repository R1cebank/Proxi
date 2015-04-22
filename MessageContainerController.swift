//
//  MessageContainerController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/22/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation

class MessageContainerController : UIViewController {
    
    @IBOutlet weak var containerTitle: UINavigationItem!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        println("MessageContainerController : loaded")
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewDidAppear(animated: Bool) {
        println("MessageContainerController : willappear")
        containerTitle.title = appDelegate.mpcManager.currentPeerID
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
}