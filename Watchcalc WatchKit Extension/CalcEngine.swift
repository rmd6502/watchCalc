//
//  CalcEngine.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/10/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import Foundation

enum MonomialOperator : String {
    case reciprocal = "1/x"
    case radical = "√"
    case sin = "sin"
    case cos = "cos"
    case tan = "tan"
    case lnx = "lnx"
    case log = "log"
    case π = "π"
    case eˣ = "eˣ"
    case x² = "x²"
    case x³ = "x³"
    case cubeRoot = "∛"
    case rnd = "rnd"
    case factorial = "x!"
    case e = "e"
    case sign = "±"
    case MR = "MR"
    case MC = "MC"
    case Mplus = "M+"
    case Mminus = "M-"
}

enum BinomialOperator : String {
    case plus = "+"
    case minus = "-"
    case times = "✕"
    case div = "÷"
    case power = "yˣ"
    case exponent = "EE"
}

class CalcEngine {
    var value = 0.0
    var memoryValue = 0.0
    var sign = 1.0
    enum Mode {
        case Operator,Operand,CalcOperand
    }
    var mode = Mode.Operand
    var operand = "0"
    var valueStack : [Double] = []
    var operatorStack : [BinomialOperator] = []
    let precedences = [BinomialOperator.plus:0,BinomialOperator.minus:0,BinomialOperator.times:1,BinomialOperator.div:1,BinomialOperator.power:2, BinomialOperator.exponent:3]
    let valueFormat = "%.10g"

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
        mode = .CalcOperand
    }

    func allClear()
    {
        clear()
        valueStack = []
        operatorStack = []
    }

    func handleMonomial(fn : MonomialOperator)
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

    func handleBinomial(fn: BinomialOperator)
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

    func executeFunction(var operation : MonomialOperator)
    {
        var value = valueStack.removeLast()
        switch operation {
        case .reciprocal:
            value = 1/value
        case .radical:
            value = sqrt(value)
        case .sin:
            value = sin(value)
        case .cos:
            value = cos(value)
        case .tan:
            value = tan(value)
        case .lnx:
            value = log(value)
        case .log:
            value = log10(value)
        case .π:
            value = M_PI
        case .eˣ:
            value = exp(value)
        case .x²:
            value = value * value
        case .x³:
            value = value * value * value
        case .cubeRoot:
            value = pow(value, 1.0/3.0)
        case .rnd:
            value = drand48()
        case .factorial:
            value = fact(value)
        case .e:
            value = M_E
        case .sign:
            value = -value
        case .MR:
            value = memoryValue
        case .MC:
            memoryValue = 0
        case .Mplus:
            memoryValue += value
        case .Mminus:
            memoryValue -= value
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

    func popStack(var lastOp : BinomialOperator? = nil)
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

    func performOperation(op : BinomialOperator, v1 : Double, v2 : Double) -> Double
    {
        switch op {
        case .plus:
            return v1 + v2
        case .minus:
            return v1 - v2
        case .div:
            return v1 / v2
        case .times:
            return v1 * v2
        case .power:
            return pow(v1, v2)
        case .exponent:
            return v1 * pow(10.0,v2)
        default:
            return 0
        }
    }

}