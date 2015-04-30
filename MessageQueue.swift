//
//  MessageQueue.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/30/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation

class MessageQueue : NSObject {
    
    var messages: [String:NSMutableArray]
    
    lazy private var messageQueuePath: String = {
        let fileManager = NSFileManager.defaultManager()
        let documentDirectoryURLs = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as! [NSURL]
        let archiveURL = documentDirectoryURLs.first!.URLByAppendingPathComponent("Proxi-Queue", isDirectory: true)
        return archiveURL.path!
    }()
    override init() {
        messages = [String:NSMutableArray]()
        super.init()
    }
    func clearForPeer(peer: String) {
        var queue = newOrGetForPeer(peer)
        queue.removeAllObjects()
    }
    func newOrGetForPeer(peer: String) -> NSMutableArray {
        var archive = NSMutableArray()
        if let a = messages[peer] {
            println("Restoring queue with: \(peer)")
            archive = a
        } else {
            println("Creating a new queue with: \(peer)")
            messages[peer] = archive
        }
        return archive
    }
    func saveMsg() {
        NSKeyedArchiver.archiveRootObject(messages, toFile: messageQueuePath)
    }
    func unarchiveSavedItems() {
        if NSFileManager.defaultManager().fileExistsAtPath(messageQueuePath) {
            messages = NSKeyedUnarchiver.unarchiveObjectWithFile(messageQueuePath) as! [String: NSMutableArray]
        }
        
    }
}