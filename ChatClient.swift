//
//  ChatClient.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/22/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ChatClient: NSObject {
    var peer: MCPeerID!
    var displayName: String!
    
    override init() {
        super.init()
        
    }
}