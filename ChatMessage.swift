//
//  ChatMessage.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/22/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation

class ChatMessage: NSObject {
    var sender: String!
    var message:  String!
    init(sdr: String, msg: String) {
        super.init()
        sender = sdr
        message = msg
    }
}