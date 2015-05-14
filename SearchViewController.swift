//
//  SearchViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/20/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import MCSwipeTableViewCell
import JDStatusBarNotification
import SIAlertView

class SearchViewController: UIViewController, UITableViewDelegate, MCSwipeTableViewCellDelegate, UITableViewDataSource, MPCManagerDelegate, BWWalkthroughViewControllerDelegate {
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
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if !userDefaults.boolForKey("walkthroughPresented") {
            
            showWalkthrough()
            
            userDefaults.setBool(true, forKey: "walkthroughPresented")
            userDefaults.synchronize()
        }
    }
    // Introduction
    func showWalkthrough(){
        
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewControllerWithIdentifier("walk") as! BWWalkthroughViewController
        let page_zero = stb.instantiateViewControllerWithIdentifier("walk0") as! UIViewController
        let page_one = stb.instantiateViewControllerWithIdentifier("walk1") as! UIViewController
        let page_two = stb.instantiateViewControllerWithIdentifier("walk2")as! UIViewController
        let page_three = stb.instantiateViewControllerWithIdentifier("walk3") as! UIViewController
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(page_one)
        walkthrough.addViewController(page_two)
        walkthrough.addViewController(page_three)
        walkthrough.addViewController(page_zero)
        
        self.presentViewController(walkthrough, animated: true, completion: nil)
    }
    func walkthroughPageDidChange(pageNumber: Int) {
        println("Current Page \(pageNumber)")
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func  viewWithImageName(imageName: String) -> UIView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = UIViewContentMode.Center
        return imageView
    }
    
    //UITableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCellPeer") as! MCSwipeTableViewCell
        //cell = MCSwipeTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "idCellPeer")
        cell.separatorInset = UIEdgeInsetsZero
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.Gray
        
        //Setup Check
        let connectView = self.viewWithImageName("link")
        let greenColor = UIColor(red: 85/255, green: 213/255, blue: 80/255, alpha: 1.0)
        let crossView = self.viewWithImageName("cross")
        let redColor = UIColor(red: 232/255, green: 61/255, blue: 14/255, alpha: 1.0)
        cell.defaultColor = self.tableView.backgroundView?.backgroundColor
        cell.setSwipeGestureWithView(connectView, color: greenColor, mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State1) {
            (cell, state, mode) -> Void in
            println("connect swiped")
            let selectedPeer = self.appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
            let peerName = self.appDelegate.mpcManager.foundPeers[indexPath.row].displayName
            let alertView = SIAlertView(title: "Invitation Sent", andMessage: "Your invitation to: \(self.appDelegate.mpcManager.getHandle(selectedPeer)) has been sent.") as SIAlertView
            alertView.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default, handler: nil)
            alertView.show()
            
            self.appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: self.appDelegate.mpcManager.newOrGetSession(peerName).session, withContext: nil, timeout: 20)
        }
        cell.setSwipeGestureWithView(crossView, color: redColor, mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State2) {
            (cell, state, mode) -> Void in
            println("cancel swiped")
        }
        
        cell.textLabel?.text = appDelegate.mpcManager.getHandleFromID(appDelegate.mpcManager.foundPeers[indexPath.row].displayName)
        cell.detailTextLabel?.text = appDelegate.mpcManager.getDisplayNameFromID(appDelegate.mpcManager.foundPeers[indexPath.row].displayName)
        
        cell.delegate = self
        
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
    /*func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
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
    }*/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
