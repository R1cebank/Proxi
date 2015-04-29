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
    init(sdr: String, msg: String) {
        super.init()
        sender = sdr
        message = msg
    }
    required init(coder aDecoder: NSCoder) {
        self.sender = aDecoder.decodeObjectForKey("sender") as! String
        self.message = aDecoder.decodeObjectForKey("message") as! String
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.sender, forKey: "sender")
        aCoder.encodeObject(self.message, forKey: "message")
    }
}