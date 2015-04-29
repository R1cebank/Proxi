//
//  ChatViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/20/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChatViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ChatManagerDelegate, YALTabBarInteracting {
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
        appDelegate.chatManager.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(animated: Bool) {
        appDelegate.chatManager.delegate = appDelegate
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "idSegueChat" {
            let controller = segue.sourceViewController as! ChatViewController
            
            println("ChatViewController : prepareForSegue")
        }
    }
    func gotMessage(receivedDataDictionary: Dictionary<String, AnyObject>) {
        //Got a message
        println("ChatViewController : gotMessage")
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        let session = receivedDataDictionary["session"] as! MCSession
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, String>
        if let message = dataDictionary["message"] {
            println("Appdelegate : handleMPC : \(message) : from : \(fromPeer.displayName)")
            //Archive
            
            let archive = appDelegate.chatManager.newOrGetArchive(fromPeer.displayName)
            let chatMessage = ChatMessage(sdr: fromPeer.displayName, msg: message)
            archive.addObject(chatMessage)
            appDelegate.chatManager.saveMsg()
            var unreadCount = appDelegate.chatManager.newOrGetUnread(fromPeer.displayName)
            if(unreadCount != -1) {
                appDelegate.chatManager.unreadFrom[fromPeer.displayName] = unreadCount + 1
            } else {
                appDelegate.chatManager.unreadFrom[fromPeer.displayName] = 1
            }
            
        }
        //JDStatusBarNotification.showWithStatus("message from \(appDelegate.mpcManager.idName[fromPeer.displayName])", dismissAfter: NSTimeInterval(2))
        dispatch_async(dispatch_get_main_queue(), {
            JDStatusBarNotification.showWithStatus("message from \(self.appDelegate.mpcManager.getHandle(fromPeer))", dismissAfter: NSTimeInterval(2))
            self.tableView.reloadData()
        })
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idChatId") as! ChatListDataCell
        var id = appDelegate.mpcManager.sessions.keys.array[indexPath.row]
        cell.peerID.text = id
        cell.peerName.text = appDelegate.mpcManager.getHandleFromID(id)
        //cell.userImage = UIImageView(image: UIImage(named: "mo"))
        //Change to load last message
        var messageList = appDelegate.chatManager.newOrGetArchive(id)
        var unreadCount = appDelegate.chatManager.newOrGetUnread(id)
        if(unreadCount <= -1) {
            println("ChatViewController : resetting badge")
            //cell.userImage = UIImageView(image: UIImage(named: "mo"))
        } else {
            let hub = RKNotificationHub(view: cell.userImage)
            hub.scaleCircleSizeBy(0.7)
            hub.setCount(unreadCount)
            hub.pop()
        }
        println("Setting \(unreadCount)")
        if(messageList.count == 0) {
            cell.lastMessage.text = "[no message]"
        } else {
            if let msg = messageList.lastObject as? ChatMessage {
                cell.lastMessage.text = msg.message
            }
        }
        //cell.lastMessage.text = "Do you want to get a burger?"
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("connect count: \(appDelegate.mpcManager.sessions.count)")
        return appDelegate.mpcManager.sessions.count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ChatListDataCell
        appDelegate.mpcManager.currentPeerHandle = cell.peerName.text
        appDelegate.mpcManager.currentPeerID = cell.peerID.text
        appDelegate.mpcManager.currentSession = appDelegate.mpcManager.sessions[cell.peerID.text!]?.session
        self.performSegueWithIdentifier("idSegueChat", sender: self)
    }
    //YAL Bar interacting
    func extraLeftItemDidPressed() {
        println("ChatViewController : extraleftPressed")
        tableView.reloadData()
    }
    
}