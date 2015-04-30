//
//  AppDelegate.swift
//  Proxi
//
//  Created by Siyuan Gao on 4/20/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import UIKit
import MultipeerConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ChatManagerDelegate {

    var window: UIWindow?
    var mpcManager: MPCManager!
    var chatManager: ChatManager!
    var messageQueue: MessageQueue!
    var filemgr:       NSFileManager!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        //Defaults
        filemgr = NSFileManager.defaultManager()
        if(NSUserDefaults.standardUserDefaults().stringForKey("handle") == nil) {
            NSUserDefaults.standardUserDefaults().setValue("Miku", forKey: "handle")
        }
        if((NSUserDefaults.standardUserDefaults().stringForKey("UUID")) == nil) {
            NSUserDefaults.standardUserDefaults().setValue(NSUUID().UUIDString, forKey: "UUID")
        }
        mpcManager = MPCManager(hdl: NSUserDefaults.standardUserDefaults().stringForKey("handle")!)
        chatManager = ChatManager(manager: mpcManager)
        chatManager.delegate = self
        chatManager.unarchiveSavedItems()
        messageQueue = MessageQueue()
        messageQueue.unarchiveSavedItems()
        //mpcManager.handle = NSUserDefaults.standardUserDefaults().stringForKey("handle")
        let UID = NSUserDefaults.standardUserDefaults().stringForKey("UUID")
        println("I am \(UID!)")
        println("My handle is \(mpcManager.handle)")
        // Override point for customization after application launch.
        NSNotificationCenter.defaultCenter().addObserver(chatManager, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)
        setupTabBarController()
        return true
    }
    
    
    
    func setupTabBarController() {
        let tabBarController = self.window!.rootViewController as! YALFoldingTabBarController
        let item1:YALTabBarItem = YALTabBarItem(itemImage: UIImage(named: "nearby_icon"), leftItemImage: nil, rightItemImage: nil)
        let item2:YALTabBarItem = YALTabBarItem(itemImage: UIImage(named: "profile_icon"), leftItemImage: nil, rightItemImage: nil)
        tabBarController.leftBarItems = [item1, item2]
        let item3 = YALTabBarItem(itemImage: UIImage(named: "new_chat_icon"), leftItemImage: UIImage(named: "reload_icon"), rightItemImage: UIImage(named: "new_chat_icon"))
        let item4 = YALTabBarItem(itemImage: UIImage(named: "settings_icon"), leftItemImage: nil, rightItemImage: nil)
        tabBarController.rightBarItems = [item3, item4]
        tabBarController.centerButtonImage = UIImage(named: "tele")
        tabBarController.selectedIndex = 0
        tabBarController.tabBarView.extraTabBarItemHeight = YALExtraTabBarItemsDefaultHeight
        tabBarController.tabBarView.offsetForExtraTabBarItems = YALForExtraTabBarItemsDefaultOffset
        tabBarController.tabBarView.backgroundColor = UIColor(red: 94/255, green: 91/255, blue: 149/255, alpha: 1)
        tabBarController.tabBarView.tabBarColor = UIColor(red: 72/255, green: 211/255, blue: 178/255, alpha: 1)
        tabBarController.tabBarViewHeight = YALTabBarViewDefaultHeight
        tabBarController.tabBarView.tabBarViewEdgeInsets = YALTabBarViewHDefaultEdgeInsets
        tabBarController.tabBarView.tabBarItemsEdgeInsets = YALTabBarViewItemsDefaultEdgeInsets
    }
    
    func gotMessage(receivedDataDictionary: Dictionary<String, AnyObject>) {
        //Got a message
        println("Appdelegate : gotMessage")
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        let session = receivedDataDictionary["session"] as! MCSession
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, String>
        if let message = dataDictionary["message"] {
            println("Appdelegate : handleMPC : \(message) : from : \(fromPeer.displayName)")
            //Archive
            let archive = chatManager.newOrGetArchive(fromPeer.displayName)
            let chatMessage = ChatMessage(sdr: fromPeer.displayName, msg: message)
            archive.addObject(chatMessage)
            chatManager.saveMsg()
        }
        dispatch_async(dispatch_get_main_queue(), {
            JDStatusBarNotification.showWithStatus("message from \(mpcManager.getHandle(fromPeer))", dismissAfter: NSTimeInterval(2))
        })
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

