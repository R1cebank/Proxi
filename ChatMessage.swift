//
//  ChatMessage.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/22/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation

class ChatMessage: NSObject, NSCoding {
    var sender: String!
    var message:  String!
    var time:     NSDate!
    init(sdr: String, msg: String, date: NSDate) {
        super.init()
        sender = sdr
        message = msg
        time = date
    }
    required init(coder aDecoder: NSCoder) {
        self.sender = aDecoder.decodeObjectForKey("sender") as! String
        self.message = aDecoder.decodeObjectForKey("message") as! String
        self.time = aDecoder.decodeObjectForKey("time") as! NSDate
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.sender, forKey: "sender")
        aCoder.encodeObject(self.message, forKey: "message")
        aCoder.encodeObject(self.time, forKey: "time")
    }
}