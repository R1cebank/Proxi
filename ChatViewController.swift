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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        println("ChatViewController : loaded")
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillAppear(animated: Bool) {
        println("ChatViewController : willappear")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "idSegueChat" {
            let controller = segue.sourceViewController as! ChatViewController
            
            println("ChatViewController : prepareForSegue")
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idChatId") as! ChatListDataCell
        cell.peerName.text = appDelegate.mpcManager.sessions.keys.array[indexPath.row]
        //Change to load last message
        cell.lastMessage.text = "Do you want to get a burger?"
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("connect count: \(appDelegate.mpcManager.sessions.count)")
        return appDelegate.mpcManager.sessions.count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ChatListDataCell
        appDelegate.mpcManager.currentPeerID = cell.peerName.text
        appDelegate.mpcManager.currentSession = appDelegate.mpcManager.sessions[cell.peerName.text!]
        self.performSegueWithIdentifier("idSegueChat", sender: self)
    }
}