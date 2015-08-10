//
//  CalcRequest.swift
//  Watchcalc
//
//  Created by Robert Diamond on 7/1/15.
//  Copyright © 2015 Robert Diamond. All rights reserved.
//

import Foundation
import WatchConnectivity

@available(iOS 9.0, *)
class CalcRequest : NSObject, WCSessionDelegate {
    let session = WCSession.defaultSession()

    class func sharedCalcRequest() -> CalcRequest
    {
        struct staticData {
            static let sharedRequest = CalcRequest()
        }
        return staticData.sharedRequest
    }

    override private init()
    {
        super.init()
        session.delegate = self
        session.activateSession()
    }

    // MARK: Requests
    func sendValue(value: Double)
    {
        if (!session.reachable) {
            return
        }
        session.transferUserInfo(["request": "newValue", "value":value])
    }

    func sendRegisterEntry(entry: CalcRegister)
    {
        if (!session.reachable) {
            return
        }
        var message : [String : AnyObject] = ["request": "appendRegister", "op1": entry.op1, "result": entry.result, "operation": entry.operation]
        if (entry.op2 != nil) {
            message["op2"] = entry.op2
        }
        session.transferUserInfo(message)
    }

    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject])
    {
        if let request = userInfo["request"] as? String {
            switch (request) {
            case "newValue":
                if let value = userInfo["value"] as? Double {
                    CalcEngine.sharedCalcEngine().resetToValue(value)
                }
            case "appendRegister":
                if let op1 = userInfo["op1"] as? Double, op2 = userInfo["op2"] as? Double?, result = userInfo["result"] as? Double, operation = userInfo["operation"] as? String {
                    CalcEngine.sharedCalcEngine().register.append(CalcRegister(op1: op1, op2: op2, result: result, operation: operation))
            }
            default:
                print("Unknown request \(request)")
            }
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