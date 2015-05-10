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
    @IBOutlet weak var tableView: WKInterfaceTable!
    var value = 0.0
    var sign = 1.0
    enum Mode {
        case Operator,Operand,CalcOperand
    }
    var mode = Mode.Operand
    var operand = "0"
    var valueStack : [Double] = []
    var operatorStack : [String] = []
    let precedences = ["+":0,"-":0,"✕":1,"÷":1]
    weak var valueLabel : WKInterfaceLabel?

    var keyBindings : [[String]]!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        tableView.setRowTypes(["ValueRow", "ButtonRow", "ButtonRow", "ButtonRow", "ButtonRow","ButtonRow"])
        var buttonIdx = 0
        var buttonWidth = (self.contentFrame.width - 16.0) / 4.0
        for (var rowNum = 0; rowNum < tableView.numberOfRows; ++rowNum) {
            switch tableView.rowControllerAtIndex(rowNum) {
            case let valueRow as ValueRow:
                valueRow.valueLabel.setText(operand)
                valueLabel = valueRow.valueLabel
            case let buttonRow as ButtonRow:
                println("key \(self.keyBindings[buttonIdx])")
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
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
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
            if mode == .Operand {
                self.pushValue()
            } else if mode == .Operator {
                operatorStack.removeLast()
            }
            self.executeFunction(button)
            mode = .CalcOperand
            if let lastValue = valueStack.last {
                operand = "\(lastValue)"
            }
        case "0"..."9",".":
            if mode != .Operand {
                operand = ""
                sign = 1
                if mode == .CalcOperand && valueStack.count > 0 {
                    valueStack.removeLast()
                }
                mode = .Operand
            }
            while valueStack.count > 0 && isnan(valueStack.last!) {
                valueStack.removeLast()
            }
            operand += button
            while operand.hasPrefix("0") && operand.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 1 {
                operand.removeAtIndex(operand.startIndex)
            }
        case "±":
            if operand != "0" {
                sign = -sign
                if sign == -1 {
                    operand.insert("-", atIndex: operand.startIndex)
                } else {
                    operand.removeAtIndex(operand.startIndex)
                }
            }
        case "C":
            if operand != "0" && operand.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                operand = "0"
                sign = 1
            } else {
                valueStack = []
                operatorStack = []
            }
            mode = .Operand
        case "=":
            if mode == .Operand {
                self.pushValue()
            }
            self.popStack()
            let result = valueStack.removeAtIndex(0)
            operand = "\(result)"
            valueStack = [result]
            operatorStack = []
            sign = 1
            mode = .CalcOperand
        default:
            if mode == .Operator {
                operatorStack.removeAtIndex(0)
            } else {
                if mode == .Operand {
                    self.pushValue()
                }
                mode = .Operator
            }
            popStack(lastOp: button)
            operatorStack.extend([button])
            if let lastValue = valueStack.last {
                operand = "\(lastValue)"
            }
        }
        valueLabel?.setText(operand)
    }

    func pushValue()
    {
        value = atof(operand.cStringUsingEncoding(NSUTF8StringEncoding)!)
        valueStack.extend([value])
    }

    func executeFunction(var operation : String)
    {
        var value = valueStack.removeLast()
        switch operation {
        case "1/x":
            value = 1 / value
        case "√":
            value = sqrt(value)
        default:
            break
        }
        valueStack.extend([value])
    }

    func popStack(var lastOp : String? = nil)
    {
        var lastOpPrec = -1
        if let lastOperator = lastOp, precedence = precedences[lastOperator] {
            lastOpPrec = precedence
        }
        println("operators \(self.operatorStack) values \(self.valueStack) lastOp \(lastOp)")
        while operatorStack.count > 0 && valueStack.count > 1 {
            let op = operatorStack.last!
            if let precedence = precedences[op] {
                if precedence < lastOpPrec {
                    break
                }
            }
            operatorStack.removeLast()
            let v2 = valueStack.removeLast()
            let v1 = valueStack.removeLast()
            let result = self.performOperation(op, v1: v1, v2: v2)
            valueStack.extend([result])
        }
    }

    func performOperation(op : String, v1 : Double, v2 : Double) -> Double
    {
        switch op {
        case "+":
            return v1 + v2
        case "-":
            return v1 - v2
        case "÷":
            return v1 / v2
        case "✕":
            return v1 * v2
        default:
            return 0
        }
    }
}
