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

@objc protocol CalcEngineDelegate {
    optional func valueChanged(newValue : Double)
    optional func memoryChanged(newValue : Double)
}

struct CalcRegister {
    var op1 : Double
    var op2 : Double?
    var result : Double
    var operation : String  // MonomialObject or BinomialObject
}

@available(iOS 9.0, *)
class CalcEngine {
    var value = 0.0 {
        didSet {
            print("set value \(self.value)")
            self.delegate?.valueChanged?(self.value)
        }
    }
    var memoryValue = 0.0 {
        willSet(newValue) {
            if memoryValue != newValue {
                self.delegate?.memoryChanged?(newValue)
            }
        }
    }
    var operandFormatted : String {
        get {
            return String(format: valueFormat, valueDigits, self.value)
        }
    }

    var sign = 1.0
    enum Mode {
        case Operator,Operand,CalcOperand
    }
    var mode = Mode.Operand
    var operand = "0"
    var valueStack : [Double] = []
    var operatorStack : [BinomialOperator] = []
    let precedences = [BinomialOperator.plus:0,BinomialOperator.minus:0,BinomialOperator.times:1,BinomialOperator.div:1,BinomialOperator.power:2, BinomialOperator.exponent:3]
    let valueFormat = "%.*g"
    var valueDigits = 10
    var delegate : CalcEngineDelegate?

    var register : [CalcRegister] = []
    let DEFAULT_MAX_REGISTER_SIZE = 20
    var maxRegisterSize : Int

    private init()
    {
        // Does nothing but ensures everyone uses the sharedEngine
        maxRegisterSize = DEFAULT_MAX_REGISTER_SIZE
        sendValueUpdate()
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
        if mode == .CalcOperand && valueStack.count > 0 {
            valueStack.removeAtIndex(0)
        }
        mode = .Operand
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
        }
        self.executeFunction(fn)
        mode = .CalcOperand
        if let lastValue = valueStack.last {
            value = lastValue
            sendValueUpdate()
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
        popStack(fn)
        operatorStack.extend([fn])
        if let lastValue = valueStack.last {
            value = lastValue
            sendValueUpdate()
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
        let savedOperand = self.operand
        self.value = atof(self.operand.cStringUsingEncoding(NSUTF8StringEncoding)!)
        operand = savedOperand
        while operand.hasPrefix("0") && operand.characters.count > 1 {
            operand.removeAtIndex(operand.startIndex)
        }
        sendValueUpdate()
    }

    func handleEqual()
    {
        if mode == .Operand {
            pushValue()
        }
        self.popStack()
        value = valueStack.removeAtIndex(0)
        valueStack = [value]
        operatorStack = []
        sign = 1
        mode = .CalcOperand
        sendValueUpdate()
    }

    func doClear()
    {
        if operand != "0" && operand.characters.count > 0 {
            clear()
        } else {
            allClear()
        }
        sendValueUpdate()
    }

    func pushValue()
    {
        value = atof(operand.cStringUsingEncoding(NSUTF8StringEncoding)!)
        valueStack.extend([value])
        sendValueUpdate()
    }

    func resetToValue(newValue : Double)
    {
        allClear()
        value = newValue
        valueStack.append(value)
        mode = .CalcOperand
    }

    func executeFunction(operation : MonomialOperator)
    {
        var value = 0.0
        if valueStack.count > 0 {
            if (mode == .Operand || mode == .CalcOperand) {
                value = valueStack.removeLast()
            } else {
                value = valueStack.last!
            }
        }
        switch operation {
        case .reciprocal:
            value = 1.0/value
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
        }
        register.append(CalcRegister(op1: value, op2: nil, result: value, operation: operation.rawValue))
        valueStack.extend([value])
        sendValueUpdate()
        sendRegisterUpdate()
    }

    func fact(value : Double) -> Double
    {
        if value <= 1 {
            return 1
        } else {
            return value * fact(value - 1)
        }
    }

    func popStack(lastOp : BinomialOperator? = nil)
    {
        var lastOpPrec = -1
        if let lastOperator = lastOp, precedence = precedences[lastOperator] {
            lastOpPrec = precedence
        }
        //println("operators \(self.operatorStack) values \(self.valueStack) lastOp \(lastOp)")
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
        var result : Double = 0
        switch op {
        case .plus:
            result = v1 + v2
        case .minus:
            result = v1 - v2
        case .div:
            result = v1 / v2
        case .times:
            result = v1 * v2
        case .power:
            result = pow(v1, v2)
        case .exponent:
            result = v1 * pow(10.0,v2)
        }
        register.append(CalcRegister(op1: v1, op2: v2, result: result, operation: op.rawValue))
        sendRegisterUpdate()
        return result
    }

    func handleButton(button : String) -> Bool
    {
        if let monomial = MonomialOperator(rawValue: button) {
            handleMonomial(monomial)
        } else if let binomial = BinomialOperator(rawValue: button) {
            handleBinomial(binomial)
        } else {
            switch button {
            case "0"..."9",".":
                handleOperand(button)
            case "C":
                doClear()
            case "=":
                handleEqual()
            default:
                print("You need to write the handler for \(button)")
                return false
            }
        }
        while register.count > maxRegisterSize {
            register.removeAtIndex(0)
        }
        return true
    }

    // MARK: communication
    func sendValueUpdate()
    {
        CalcRequest.sharedCalcRequest().sendValue(self.value)
    }

    func sendRegisterUpdate()
    {
        if let lastEntry = self.register.last {
            CalcRequest.sharedCalcRequest().sendRegisterEntry(lastEntry)
        }
    }
}