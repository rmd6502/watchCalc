//
//  CalcRequest.swift
//  Watchcalc
//
//  Created by Robert Diamond on 7/1/15.
//  Copyright © 2015 Robert Diamond. All rights reserved.
//

import Foundation
import WatchConnectivity

class CalcRequest : NSObject, WCSessionDelegate {
    let session = WCSession.defaultSession()

    override init()
    {
        super.init()
        session.delegate = self
        session.activateSession()
    }

    // MARK: Requests
    func sendValue(value: Double)
    {
        session.sendMessage(["value":value], replyHandler: { (reply) -> Void in
            print("Got reply: \(reply)")
        }) { (error) -> Void in
            print("Received Error: \(error)")
        }
    }

    // MARK: Session Delegate
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?)
    {
        if error != nil {
            print("Failed to send watchkit message: \(error?.localizedDescription)")
        }
    }
}