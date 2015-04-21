//
//  SearchViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/20/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    
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
    // MPC func
    func foundPeer() {
        tableView.reloadData()
        println("found peer")
    }
    func lostPeer() {
        tableView.reloadData()
        println("lost peer")
    }
    func invitationWasReceived(fromPeer: String) {
        let alertView = SIAlertView(title: "Invitation Recieved", andMessage: "\(fromPeer) want to chat with you.")
        alertView.show()
    }
    func connectedWithPeer(peerID: MCPeerID) {
        println("connected")
    }
    
    //UITableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCellPeer") as! UITableViewCell
        cell.textLabel?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
        
        appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
