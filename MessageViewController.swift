//
//  MessageViewController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/21/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity
import JSQMessagesViewController
import JDStatusBarNotification
import RandomColorSwift

class MessageViewController : JSQMessagesViewController, ChatManagerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    var messages = [JSQMessage]()
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 72/255, green: 211/255, blue: 178/255, alpha: 1))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 94/255, green: 91/255, blue: 149/255, alpha: 1))
    var selfAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("1", backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: 30)
    var foreignAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("2", backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: 30)
    var selfColor = randomColor()
    var foreignColor = randomColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = appDelegate.mpcManager.peer.displayName
        self.senderDisplayName = appDelegate.mpcManager.handle
        self.inputToolbar.contentView.leftBarButtonItem = nil
        var defaultAvatarSize: CGSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault)
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = defaultAvatarSize
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = defaultAvatarSize
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    override func viewWillAppear(animated: Bool) {
        //Restore chat message
        var messageList = appDelegate.chatManager.newOrGetArchive(appDelegate.mpcManager.currentPeerID)
        for message in messageList{
            let message = message as! ChatMessage
            println("MesssageViewController : restoring \(message.message!) from: \(appDelegate.mpcManager.getDisplayNameFromID(message.sender)) name: \(appDelegate.mpcManager.getHandleFromID(message.sender))")
            var msg = JSQMessage(senderId: message.sender, displayName: appDelegate.mpcManager.getDisplayNameFromID(message.sender), text: message.message)
            messages += [msg]
        }
        appDelegate.chatManager.unreadFrom[appDelegate.mpcManager.currentPeerID] = -1
        println("Resetting unreadCount from \(appDelegate.mpcManager.currentPeerID)")
        selfColor = randomColor()
        foreignColor = randomColor()
        selfAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(getInitial(appDelegate.mpcManager.handle), backgroundColor: selfColor, textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: 30)
        foreignAvatar =  JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(getInitial(appDelegate.mpcManager.currentPeerHandle), backgroundColor: foreignColor, textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: 30)
        self.collectionView.reloadData()
        //Restore delegate
        appDelegate.chatManager.delegate = self
    }
    override func viewWillDisappear(animated: Bool) {
        //Restore delegate
        appDelegate.chatManager.delegate = appDelegate
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotMessage(receivedDataDictionary: Dictionary<String, AnyObject>) {
        //Got a message
        println("MessageViewController : gotMessage")
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        let session = receivedDataDictionary["session"] as! MCSession
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, String>
        if let message = dataDictionary["message"] {
            println("MessageViewController : handleMPC : \(message) : from : \(fromPeer.displayName)")
            //Archive
            
            let archive = appDelegate.chatManager.newOrGetArchive(fromPeer.displayName)
            let chatMessage = ChatMessage(sdr: fromPeer.displayName, msg: message, date: NSDate())
            archive.addObject(chatMessage)
            appDelegate.chatManager.saveMsg()
            if(fromPeer.displayName == appDelegate.mpcManager.currentPeerID) {
                var msg = JSQMessage(senderId: appDelegate.mpcManager.getDisplayName(fromPeer), displayName: appDelegate.mpcManager.getHandle(fromPeer), text: message)
                messages += [msg]
                dispatch_async(dispatch_get_main_queue(), {self.finishReceivingMessageAnimated(true)})
            } else {
                var unreadCount = appDelegate.chatManager.newOrGetUnread(fromPeer.displayName)
                if(unreadCount != -1) {
                    appDelegate.chatManager.unreadFrom[fromPeer.displayName] = unreadCount + 1
                } else {
                    appDelegate.chatManager.unreadFrom[fromPeer.displayName] = 1
                }
                dispatch_async(dispatch_get_main_queue(), {
                    JDStatusBarNotification.showWithStatus("message from \(self.appDelegate.mpcManager.getHandle(fromPeer))", dismissAfter: NSTimeInterval(2))
                })
            }
            println("MessageViewController : added message : \(message) from: \(fromPeer.displayName)")
        }
        //self.finishReceivingMessageAnimated(true)
    }
    
    //Message handling part
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        var currentTime = NSDate()
        var message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text)
        //Sending through session
        let messageDictionary: [String: String] = ["message": text]
        if(appDelegate.mpcManager.currentSession.connectedPeers.count < 1) {
            var queue = appDelegate.messageQueue.newOrGetForPeer(appDelegate.mpcManager.currentPeerID)
            queue.addObject(ChatMessage(sdr: appDelegate.mpcManager.peer.displayName, msg: text, date: currentTime))
            appDelegate.messageQueue.saveMsg()
        }
        else {
            if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.currentSession.connectedPeers[0] as! MCPeerID){
                println("MessageViewController : Message is sent")
            }
            else{
                println("MessageViewController : Message could not send")
            }
        }
        //Archive
        
        let archive = appDelegate.chatManager.newOrGetArchive(appDelegate.mpcManager.currentPeerID)
        let chatMessage = ChatMessage(sdr: appDelegate.mpcManager.peer.displayName, msg: text, date: currentTime)
        archive.addObject(chatMessage)
        appDelegate.chatManager.saveMsg()
        self.messages += [message]
        self.finishSendingMessageAnimated(true)
        println("MessageViewController : didPressSendButton : \(text) : \(senderId)")
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        var data = self.messages[indexPath.row]
        return data
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var data = self.messages[indexPath.row]
        if (data.senderId == self.senderId) {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        var data = self.messages[indexPath.row]
        if (data.senderId == self.senderId) {
            return self.selfAvatar
        } else {
            return self.foreignAvatar
        }
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count;
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        var archive = appDelegate.chatManager.newOrGetArchive(appDelegate.mpcManager.currentPeerID) as NSMutableArray
        var archiveData = archive.objectAtIndex(indexPath.row) as! ChatMessage
        println("MessageViewController : \(archiveData.message) testing for inQueue")
        if(appDelegate.messageQueue.isInQueue(appDelegate.mpcManager.currentPeerID, message: archiveData)) {
            return NSAttributedString(string: "archived - will send when in range")
        } else {
            return nil
        }
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var archive = appDelegate.chatManager.newOrGetArchive(appDelegate.mpcManager.currentPeerID) as NSMutableArray
        var archiveData = archive.objectAtIndex(indexPath.row) as! ChatMessage
        println("MessageViewController : \(archiveData.message) testing for inQueue")
        if(appDelegate.messageQueue.isInQueue(appDelegate.mpcManager.currentPeerID, message: archiveData)) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0
        }
    }
    // CellBottomLabel
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        var data = self.messages[indexPath.row]
        if (data.senderId == self.senderId) {
            return NSAttributedString(string: appDelegate.mpcManager.handle)
        } else {
            return NSAttributedString(string: appDelegate.mpcManager.currentPeerHandle)
        }
    }
    
    // CellBottomLabel height
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
}