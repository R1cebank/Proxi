//
//  SearchViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/20/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import SWTableViewCell
import JDStatusBarNotification
import SIAlertView

class SearchViewController: UIViewController, UITableViewDelegate, SWTableViewCellDelegate, UITableViewDataSource, MPCManagerDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var visibilityIndicator: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        appDelegate.mpcManager.delegate = self
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        if(NSUserDefaults.standardUserDefaults().boolForKey("isVisible")) {
            appDelegate.mpcManager.startAdvertising()
        } else {
            appDelegate.mpcManager.stopAdvertising()
        }
    }
    override func viewDidAppear(animated: Bool) {
        if(NSUserDefaults.standardUserDefaults().boolForKey("isVisible")) {
            visibilityIndicator.text = "VISIBLE TO OTHERS"
        } else {
            visibilityIndicator.text = "NOT VISIBLE TO OTHERS"
        }
    }
    // MPC func
    func foundPeer() {
        tableView.reloadData()
        JDStatusBarNotification.showWithStatus("peer found", dismissAfter: NSTimeInterval(2), styleName: "JDStatusBarStyleSuccess")
        println("found peer")
    }
    func lostPeer() {
        tableView.reloadData()
        JDStatusBarNotification.showWithStatus("peer lost", dismissAfter: NSTimeInterval(2), styleName: "JDStatusBarStyleError")
        println("lost peer")
    }
    func invitationWasReceived(fromPeer: String) {
        let alertView = SIAlertView(title: "Invitation Recieved", andMessage: "\(appDelegate.mpcManager.getHandleFromID(fromPeer)) want to chat with you.")
        alertView.addButtonWithTitle("Accept", type: SIAlertViewButtonType.Default) {
            (alertView) -> Void in
            println("AcceptedPeer: \(fromPeer)")
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.newOrGetSession(fromPeer).session)
        }
        alertView.addButtonWithTitle("Decline", type: SIAlertViewButtonType.Cancel) {
            (alertView) -> Void in
            println("DeclinedPeer: \(fromPeer)")
            self.appDelegate.mpcManager.invitationHandler(false, nil)
        }

        alertView.show()
    }
    func connectedWithPeer(peerID: MCPeerID) {
        println("connected")
        var queue = appDelegate.messageQueue.newOrGetForPeer(peerID.displayName)
        for msg in queue {
            let msg = msg as! ChatMessage
            let text = msg.message
            let messageDictionary: [String: String] = ["message": text]
            if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.currentSession.connectedPeers[0] as! MCPeerID){
                println("SearchViewController : Queued Message is sent")
            }
            else{
                println("SearchViewController : Message could not send")
            }
        }
        queue.removeAllObjects()
        appDelegate.messageQueue.saveMsg()
    }
    
    //UITableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCellPeer") as! AvaliablePeerCell
        //Set left buttons
        var leftButtons = NSMutableArray()
        leftButtons.sw_addUtilityButtonWithColor(UIColor(red: 72/255, green: 211/255, blue: 178/255, alpha: 1), icon: UIImage(named: "connect"))
        cell.leftUtilityButtons = leftButtons as [AnyObject]
        //Set right buttons
        cell.peerID?.text = appDelegate.mpcManager.getDisplayNameFromID(appDelegate.mpcManager.foundPeers[indexPath.row].displayName)
        cell.randomName?.text = appDelegate.mpcManager.getHandleFromID(appDelegate.mpcManager.foundPeers[indexPath.row].displayName)
        cell.delegate = self
        //cell.textLabel?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(appDelegate.mpcManager.sessions.count <= indexPath.row) {
            return 60
        }
        var id = appDelegate.mpcManager.sessions.keys.array[indexPath.row]
        if(appDelegate.chatManager.messageArchive[id] != nil) {
            return 0
        } else {
            return 60
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        let indexPath = self.tableView.indexPathForCell(cell)
        let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath!.row] as MCPeerID
        let peerName = appDelegate.mpcManager.foundPeers[indexPath!.row].displayName
        switch(index) {
        case 0:
            let alertView = SIAlertView(title: "Invitation Sent", andMessage: "Your invitation to: \(appDelegate.mpcManager.getHandle(selectedPeer)) has been sent.") as SIAlertView
            alertView.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default, handler: nil)
            alertView.show()
            
            appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.newOrGetSession(peerName).session, withContext: nil, timeout: 20)
            break;
        default:
            break;
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
