//
//  InterfaceController.swift
//  Watchcalc WatchKit Extension
//
//  Created by Robert Diamond on 5/5/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import WatchConnectivity
import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, CalcEngineDelegate, WCSessionDelegate, ValueDisplay {
    weak var tableView: WKInterfaceTable!
    weak var valueLabel : WKInterfaceLabel?

    weak var extensionDelegate : ExtensionDelegate!

    var engine : CalcEngine
    var keyBindings : [[String]]!
    let notificationCenter = DarwinNotificationCenter()
    var sharedDefaults : NSUserDefaults!

    override init() {
        engine = CalcEngine.sharedCalcEngine()
        super.init()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        engine.allClear()
        WCSession.defaultSession().delegate = self
        tableView.setRowTypes(["ValueRow", "ButtonRow", "ButtonRow", "ButtonRow", "ButtonRow","ButtonRow"])
        var buttonIdx = 0
        let buttonWidth = (self.contentFrame.width - 16.0) / 4.0
        for (var rowNum = 0; rowNum < tableView.numberOfRows; ++rowNum) {
            switch tableView.rowControllerAtIndex(rowNum) {
            case let valueRow as ValueRow:
                valueRow.valueLabel.setText(engine.operand)
                valueRow.mainGroup?.setWidth(self.contentFrame.width)
                valueLabel = valueRow.valueLabel
            case let buttonRow as ButtonRow:
                buttonRow.mainGroup?.setWidth(self.contentFrame.width)
                buttonRow.keys = self.keyBindings[buttonIdx++]
                buttonRow.buttonWidth = buttonWidth
                buttonRow.buttonPressedBlock = { [unowned self] (button) in
                    self.buttonPressed(button)
                }
            default:
                break
            }
        }
        sharedDefaults = NSUserDefaults(suiteName: "group.com.robertdiamond.watchscicalc")
        if let storedValue = sharedDefaults?.doubleForKey("value") {
            engine.resetToValue(storedValue)
        }
        if let storedValue = sharedDefaults?.doubleForKey("memory") {
            engine.memoryValue = storedValue
        }
        engine.delegate = self

        if let extDelegate = WKExtension.sharedExtension().delegate as? ExtensionDelegate {
            self.extensionDelegate = extDelegate
            self.extensionDelegate.registerValueDisplay(self)
        }
    }

    override func willActivate() {
        valueLabel?.setText(engine.operand)
        super.willActivate()
        notificationCenter.addObserver(self, selector: "resetValue:", name: "button", userInfo: nil)
    }

    override func didDeactivate() {
        super.didDeactivate()
        valueLabel?.setText(nil)
        notificationCenter.removeObserver(self)
    }

    func updateValue(value: Double) {
        
    }

    func resetValue(userInfo : [NSObject : AnyObject]?)
    {
//        WKInterfaceController.openParentApplication(["request": "value"], reply: { (userInfo, error) -> Void in
//            if let newValue = userInfo["value"] as? Double {
//                self.engine.resetToValue(newValue)
//            } else {
//                print("Failed: userInfo \(userInfo) error \(error)")
//            }
//        })
    }

    func buttonPressed(button: String) {
        engine.handleButton(button)

//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self]() -> Void in
//            if let strongSelf = self {
//                WKInterfaceController.openParentApplication(["request": "newValue", "value": strongSelf.engine.value], reply: { (userInfo, error) -> Void in
//                    print("userInfo \(userInfo) error \(error)")
//                })
//                strongSelf.updateUserActivity("com.robertdiamond.watchscicalc.value", userInfo: ["value": strongSelf.engine.value], webpageURL: nil)
//
//                strongSelf.sharedDefaults?.setDouble(strongSelf.engine.value, forKey: "value")
//                strongSelf.sharedDefaults?.synchronize()
//            }
//        })
    }

    func valueChanged(newValue: Double) {
        self.extensionDelegate.updateAllDisplays(newValue)
    }

    func memoryChanged(newValue: Double) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.sharedDefaults?.setDouble(self.engine.value, forKey: "memory")
            self.sharedDefaults?.synchronize()
        })
    }
}
