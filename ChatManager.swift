//
//  ChatManager.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/22/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ChatManagerDelegate {
    func gotMessage(receivedDataDictionary: Dictionary<String, AnyObject>)
}


class ChatManager: NSObject {
    
    var delegate: ChatManagerDelegate?
    var mpcManager: MPCManager!
    var currentSession: MCSession!
    var messageArchive = [String:NSMutableArray]()
    var unreadFrom = [String:Int32]()
    
    init(manager: MPCManager) {
        super.init()
        mpcManager = manager
    }
    func newOrGetUnread(clientID: String) -> Int32 {
        var count: Int32 = -1
        
        if let a = unreadFrom[clientID] {
            println("Restoring unreadCount with: \(clientID)")
            count = a
        } else {
            println("Creating a new unreadCount with: \(clientID)")
            unreadFrom[clientID] = count
        }
        
        return count
    }
    func newOrGetArchive(clientID: String) -> NSMutableArray {
        var archive = NSMutableArray()
        if let a = messageArchive[clientID] {
            println("Restoring archive with: \(clientID)")
            archive = a
        } else {
            println("Creating a new archive with: \(clientID)")
            messageArchive[clientID] = archive
        }
        return archive
    }
    //Handle inner application notifications
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        delegate?.gotMessage(receivedDataDictionary)
        /*
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        let session = receivedDataDictionary["session"] as! MCSession
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, String>
        if let message = dataDictionary["message"] {
            println("ChatManager : handleMPC : \(message) : from : \(fromPeer.displayName)")
            let archive = newOrGetArchive(fromPeer.displayName)
            let chatMessage = ChatMessage(sender: false, msg: message)
            archive.addObject(chatMessage)
        }*/
    }
}