//
//  WKExtensionDelegate.swift
//  Watchcalc
//
//  Created by Robert Diamond on 6/14/15.
//  Copyright © 2015 Robert Diamond. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

protocol ValueDisplay {
    func updateValue(value : Double)
}

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    var valueDisplays : [ValueDisplay] = []

    func registerValueDisplay(display : ValueDisplay)
    {
        valueDisplays.append(display)
    }

    func updateAllDisplays(value : Double)
    {
        for display in self.valueDisplays {
            display.updateValue(value)
        }
    }

    func applicationDidFinishLaunching() {
        WCSession.defaultSession().delegate = self
        WCSession.defaultSession().activateSession()
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject])
    {
        
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
}
