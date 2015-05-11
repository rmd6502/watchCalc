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

    var engine : CalcEngine

    var keyBindings : [[String]]!

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
        super.willActivate()
        valueLabel?.setText("\(engine.value)")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func buttonPressed(button: String) {
        switch button {
        case "1/x":
            fallthrough
        case "√":
            fallthrough
        case "sin":
            fallthrough
        case "cos":
            fallthrough
        case "tan":
            fallthrough
        case "lnx":
            fallthrough
        case "log":
            fallthrough
        case "π":
            fallthrough
        case "eⁿ":
            fallthrough
        case "lnx":
            fallthrough
        case "log":
            fallthrough
        case "x²":
            fallthrough
        case "x³":
            fallthrough
        case "∛":
            fallthrough
        case "rnd":
            fallthrough
        case "x!":
            fallthrough
        case "e":
            engine.handleMonomial(button)
        case "0"..."9",".":
            engine.handleOperand(button)
        case "±":
            engine.flipSign()
        case "C":
            engine.doClear()
        case "=":
            engine.handleEqual()
        default:
            engine.handleBinomial(button)
        }
        valueLabel?.setText(engine.operand)
    }

}
