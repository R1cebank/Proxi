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

class MessageViewController : JSQMessagesViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    var messages = [JSQMessage]()
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 72/255, green: 211/255, blue: 178/255, alpha: 1))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 94/255, green: 91/255, blue: 149/255, alpha: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = appDelegate.mpcManager.peer.displayName
        self.senderDisplayName = "miku"
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Message handling part
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        var message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text)
        self.messages += [message]
        //Sending through session
        let messageDictionary: [String: String] = ["message": text]
        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.currentSession.connectedPeers[0] as! MCPeerID){
            println("MessageViewController : Message is sent")
        }
        else{
            println("MessageViewController : Message could not send")
        }
        
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
        return nil
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    
}