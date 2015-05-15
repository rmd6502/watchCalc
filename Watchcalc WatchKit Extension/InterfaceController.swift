//
//  InterfaceController.swift
//  Watchcalc WatchKit Extension
//
//  Created by Robert Diamond on 5/5/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, CalcEngineDelegate {
    weak var tableView: WKInterfaceTable!
    weak var valueLabel : WKInterfaceLabel?

    static var allValueLabels : [WKInterfaceLabel] = []
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
        tableView.setRowTypes(["ValueRow", "ButtonRow", "ButtonRow", "ButtonRow", "ButtonRow","ButtonRow"])
        var buttonIdx = 0
        var buttonWidth = (self.contentFrame.width - 16.0) / 4.0
        for (var rowNum = 0; rowNum < tableView.numberOfRows; ++rowNum) {
            switch tableView.rowControllerAtIndex(rowNum) {
            case let valueRow as ValueRow:
                valueRow.valueLabel.setText(engine.operand)
                valueRow.mainGroup?.setWidth(self.contentFrame.width)
                valueLabel = valueRow.valueLabel
                if valueLabel != nil {
                    InterfaceController.allValueLabels.append(valueLabel!)
                }
            case let buttonRow as ButtonRow:
                println("key \(self.keyBindings[buttonIdx])")
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
        sharedDefaults = NSUserDefaults(suiteName: "com.robertdiamond.watchscicalc")
        if let storedValue = sharedDefaults?.doubleForKey("value") {
            engine.resetToValue(storedValue)
        }
        if let storedValue = sharedDefaults?.doubleForKey("memory") {
            engine.memoryValue = storedValue
        }
    }

    override func willActivate() {
        valueLabel?.setText(engine.operand)
        super.willActivate()
        notificationCenter.addObserver(self, selector: "resetValue:", name: "button", userInfo: nil)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        notificationCenter.removeObserver(self)
    }

    func resetValue(userInfo : [NSObject : AnyObject]?)
    {
        WKInterfaceController.openParentApplication(["request": "value"], reply: { (userInfo, error) -> Void in
            if let newValue = userInfo["value"] as? Double {
                self.engine.resetToValue(newValue)
            } else {
                println("Failed: userInfo \(userInfo) error \(error)")
            }
        })
    }

    func buttonPressed(button: String) {
        engine.handleButton(button)
    }

    func valueChanged(newValue: Double) {
        valueLabel?.setText(engine.operand)
        for (var label) in InterfaceController.allValueLabels {
            if label != valueLabel {
                label.setText(engine.operand)
            }
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self]() -> Void in
            if let strongSelf = self {
                WKInterfaceController.openParentApplication(["request": "newValue", "value": strongSelf.engine.value], reply: { (userInfo, error) -> Void in
                    println("userInfo \(userInfo) error \(error)")
                })
                strongSelf.updateUserActivity("com.robertdiamond.watchscicalc.value", userInfo: ["value": strongSelf.engine.value], webpageURL: nil)

                strongSelf.sharedDefaults?.setDouble(strongSelf.engine.value, forKey: "value")
                strongSelf.sharedDefaults?.synchronize()
            }
        })
    }

    func memoryChanged(newValue: Double) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.sharedDefaults?.setDouble(self.engine.value, forKey: "memory")
            self.sharedDefaults?.synchronize()
        })
    }
}
