//
//  ChatNavController.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/21/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit

class ChatNavController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.navigationController?.pushViewController(ChatViewController(), animated: false)
    }
    override func prepareForSegue(segue: UIStoryboardSegue,
        sender: AnyObject?) {
            if segue.identifier == "idSegueChat" {
                let detailViewController = segue.destinationViewController
                    as! MessageViewController
                println("Segue : chatSegue [prepared]")
                //let myIndexPath = self.tableView.indexPathForSelectedRow()
                //let row = myIndexPath?.row
                //detailViewController.webSite = webAddresses[row!]
            }
    }
}
