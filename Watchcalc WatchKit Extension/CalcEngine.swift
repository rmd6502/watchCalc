//
//  CalcEngine.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/10/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import Foundation

class CalcEngine {
    var value = 0.0
    var sign = 1.0
    enum Mode {
        case Operator,Operand,CalcOperand
    }
    var mode = Mode.Operand
    var operand = "0"
    var valueStack : [Double] = []
    var operatorStack : [String] = []
    let precedences = ["+":0,"-":0,"✕":1,"÷":1,"xⁿ":2]
    let valueFormat = "%g"

    private init()
    {
        
    }

    class func sharedCalcEngine() -> CalcEngine
    {
        struct StaticValues {
            static var once : dispatch_once_t = 0
            static var sharedEngine : CalcEngine? = nil
        }
        dispatch_once(&StaticValues.once, { () -> Void in
            StaticValues.sharedEngine = CalcEngine()
        })
        return StaticValues.sharedEngine!
    }

    func clear()
    {
        value = 0.0
        operand = "0"
        sign = 1
        mode = .Operand
    }

    func allClear()
    {
        clear()
        valueStack = []
        operatorStack = []
    }

    func handleMonomial(fn : String)
    {
        if mode == .Operand {
            pushValue()
        } else if mode == .Operator {
            operatorStack.removeLast()
        }
        self.executeFunction(fn)
        mode = .CalcOperand
        if let lastValue = valueStack.last {
            value = lastValue
            operand = String(format: valueFormat, value)
        }
    }

    func handleBinomial(fn: String)
    {
        if mode == .Operator {
            operatorStack.removeAtIndex(0)
        } else {
            if mode == .Operand {
                self.pushValue()
            }
            mode = .Operator
        }
        popStack(lastOp: fn)
        operatorStack.extend([fn])
        if let lastValue = valueStack.last {
            value = lastValue
            operand = String(format: valueFormat, value)
        }
    }

    func handleOperand(button : String)
    {
        if mode != .Operand {
            sign = 1
            if mode == .CalcOperand && valueStack.count > 0 {
                valueStack.removeLast()
            }
            mode = .Operand
            operand = ""
        }
        while valueStack.count > 0 && isnan(valueStack.last!) {
            valueStack.removeLast()
        }
        operand += button
        while operand.hasPrefix("0") && count(operand) > 1 {
            operand.removeAtIndex(operand.startIndex)
        }
    }

    func handleEqual()
    {
        if mode == .Operand {
            pushValue()
        }
        self.popStack()
        value = valueStack.removeAtIndex(0)
        operand = String(format: valueFormat, value)
        valueStack = [value]
        operatorStack = []
        sign = 1
        mode = .CalcOperand
    }

    func doClear()
    {
        if operand != "0" && count(operand) > 0 {
            clear()
        } else {
            allClear()
        }
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
            value = 1/value
        case "√":
            value = sqrt(value)
        case "sin":
            value = sin(value)
        case "cos":
            value = cos(value)
        case "tan":
            value = tan(value)
        case "lnx":
            value = log(value)
        case "log":
            value = log10(value)
        case "π":
            value = M_PI
        case "eⁿ":
            value = exp(value)
        case "x²":
            value = value * value
        case "x³":
            value = value * value * value
        case "∛":
            value = pow(value, 1.0/3.0)
        case "rnd":
            value = drand48()
        case "x!":
            value = fact(value)
        case "e":
            value = M_E
        case "±":
            value = -value
        default:
            break
        }
        valueStack.extend([value])
    }

    func fact(value : Double) -> Double
    {
        if value <= 1 {
            return 1
        } else {
            return value * fact(value - 1)
        }
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
        case "xⁿ":
            return pow(v1, v2)
        default:
            return 0
        }
    }

}