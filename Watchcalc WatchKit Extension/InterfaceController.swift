//
//  InterfaceController.swift
//  Watchcalc WatchKit Extension
//
//  Created by Robert Diamond on 5/5/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    weak var tableView: WKInterfaceTable!
    weak var valueLabel : WKInterfaceLabel?

    static var allValueLabels : [WKInterfaceLabel] = []
    var engine : CalcEngine
    var keyBindings : [[String]]!
    let notificationCenter = DarwinNotificationCenter()

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
                self.valueLabel?.setText(self.engine.operand)
            } else {
                println("Failed: userInfo \(userInfo) error \(error)")
            }
        })
    }

    func buttonPressed(button: String) {
        engine.handleButton(button)
        
        valueLabel?.setText(engine.operand)
        for (var label) in InterfaceController.allValueLabels {
            if label != valueLabel {
                label.setText(engine.operand)
            }
        }
        WKInterfaceController.openParentApplication(["request": "newValue", "value": engine.value], reply: { (userInfo, error) -> Void in
            println("userInfo \(userInfo) error \(error)")
        })
        self.updateUserActivity("com.robertdiamond.watchscicalc.value", userInfo: ["value": engine.value], webpageURL: nil)
    }
}
