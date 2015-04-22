//
//  ChatViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/20/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChatViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idChatId") as! AvaliablePeerCell
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}