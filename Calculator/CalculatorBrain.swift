//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Mario Youssef on 2015-04-30.
//  Copyright (c) 2015 Mario Youssef. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible { //": printable" is a protocol
        case Operand(Double)
        case NullaryOperation(String, () -> Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
        
        var description: String { //no set because read only
            get {
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case .NullaryOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = Array<Op>/* or [Op]*/()
    
    private var knownOps = Dictionary<String, Op>/*or [String:Op]*/()
    
    var variableValues = Dictionary<String, Double> /*or [String:Double]*/()
    
    init() {
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−") { $0 - $1 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin") {sin($0*(M_PI)/180)}
        knownOps["cos"] = Op.UnaryOperation("cos") {cos($0*(M_PI)/180)}
        knownOps["π"] = Op.NullaryOperation("π", {M_PI})
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {// guaranteed to return PropertyList
        get{
            return opStack.map { $0.description }
        }
        set{
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    }
                    else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    var description: String {
        get{
            var (result, ops) = ("",opStack)
            repeat {
                var current: String?
                (current, ops) = description(ops)
            result = result == "" ? current! : "\(current!), \(result)"
            } while ops.count>0
            return result
        }
    }
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (String(format: "%g", operand) , remainingOps)
            case .NullaryOperation(let symbol, _):
                return (symbol, remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = description(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = description(remainingOps)
                if var operand1 = op1Evaluation.result {
                    if remainingOps.count - op1Evaluation.remainingOps.count > 2 {
                        operand1 = "(\(operand1))"
                    }
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("\(operand2) \(symbol) \(operand1)", op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                return (symbol, remainingOps)
            }
        }
        return ("?", ops)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                return (operand, remainingOps)
            case .NullaryOperation(_, let operation):
                return (operation(), remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable (let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func showOpStack() -> String? {
        return opStack.map{ "\($0)"}.joinWithSeparator(" ")
        
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
}