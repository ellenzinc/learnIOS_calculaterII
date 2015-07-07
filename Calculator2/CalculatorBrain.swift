//
//  CalculatorBrain.swift
//  Calculator2
//
//  Created by Haining Wang on 6/25/15.
//  Copyright (c) 2015 usDream. All rights reserved.
//

import Foundation

class CalculatorBrain: Printable
{
    private enum Op: Printable
    {
        case Operand(Double)
        case VariableOperand(String, Double?)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case ConstantOperation(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .VariableOperand(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .ConstantOperation(_):
                    return "𝜋"
                }
            }
        }
    }
    
    //var opStack = Array<Op>()
    private var opStack = [Op]()
    
    //var knowOps = Dictionary<String, Op>()
    private var knownOps = [String:Op]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        //learnOp(Op.BinaryOperation("x", *))
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷"){ $1 / $0 }// the order is different
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−"){ $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["π"] = Op.ConstantOperation("π")
        learnOp(Op.VariableOperand("M",  variableValues["M"]))
        //knownOps["M"] = Op.VariableOperand("M", variableValues["M"])
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList { // guaranteed to be a PropertyList
        get  {
            return opStack.map{ $0.description }
        /*    var returnValue = Array<String>()
            for op in opStack {
                returnValue.append(op.description)
            }
            return returnValue */
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol]{
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op])-> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .ConstantOperation(_):
                remainingOps.append(.Operand(M_PI))
                return(M_PI, remainingOps)
            case .VariableOperand(_, let operand):
                return (variableValues["M"], remainingOps)
            }

            
        }
        return (nil, ops)
    }
    
    func history() -> String {
        return "\(opStack)"
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func reset() {
        opStack = [Op]()
        variableValues = [String: Double]()
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    // allow pushing variables onto the stack
    func pushOperand(symbol: String) -> Double? {
        if let operand = variableValues[symbol]{
            opStack.append(Op.Operand(operand))
            return evaluate()
        } else {
            return nil
        }
    }
    
    var variableValues = [String: Double]()
    
    func setVariableValues(value: Double?) -> Double? {
        if let MValue = value {
            variableValues["M"] = MValue
        }
        return evaluate()
    }
    
    
    private func brainDescription(ops: [Op])->(result: String, remainingOps: [Op]){
        if (!ops.isEmpty){
            var remainingOps = ops
            var result = ""
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(op)", remainingOps)
            case .UnaryOperation(let symbol, _):
                let resultPrevious = brainDescription(remainingOps)
                remainingOps = resultPrevious.remainingOps
                if (resultPrevious.result == "" && remainingOps.isEmpty){
                    result = symbol + "?"
                } else {
                    result =  symbol + "(" + resultPrevious.result + ")"
                }
                return (result, remainingOps)

            case .BinaryOperation(let symbol, _):
                let secondResult = brainDescription(remainingOps)
                remainingOps = secondResult.remainingOps
                if (secondResult.result == "" &&  remainingOps.isEmpty){
                    result = "?" + symbol + "?"
                } else {
                    let firstResult = brainDescription(remainingOps)
                    remainingOps = firstResult.remainingOps
                    var secondString  = secondResult.result
                    if (symbol == "×" || symbol == "÷" && NSNumberFormatter().numberFromString(secondResult.result)?.doubleValue == nil){
                        secondString = "(" + secondString + ")"
                    }
                    if (firstResult.result == "" && remainingOps.isEmpty){
                        result =  "?" + symbol + secondString
                    } else {
                        result = firstResult.result + symbol + secondString
                    }
                }
        
                return (result, remainingOps)
            case .ConstantOperation(let symbol):
                return (symbol, remainingOps)
            case .VariableOperand(let symbol, _):
                return (symbol, remainingOps)
            }
        }
        return ("", ops)
    }
    
    var description: String {
        get{
            var remainingOps = opStack
            var result = String()
            if (!remainingOps.isEmpty){
                result = " ="
            }
            while(!remainingOps.isEmpty){
                let currentResult = brainDescription(remainingOps)
                if (result != " ="){
                    result = "," + result
                }
                result =  currentResult.result + result
                remainingOps = currentResult.remainingOps
            }
            
            return result
        }
    }
}