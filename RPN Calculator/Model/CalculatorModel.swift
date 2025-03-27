//
//  CalculatorModel.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 08/03/25.
//

import Foundation

protocol CalculatorModelProtocol {
    func convertToRPN(_ infixExpression: [String]) -> [String]
    func calculateRPN(_ rpnExpression: [String]) -> Double
}

struct CalculatorModel: CalculatorModelProtocol {
    func convertToRPN(_ infixExpression: [String]) -> [String] {
        var operatorsStack: Stack<String> = Stack<String>()
        var output: [String] = []
        
        for element in infixExpression {
            if Double(element) != nil {
                output.append(element)
            } else if element == Button.openParenthesis.rawValue {
                operatorsStack.push(element)
            } else if element == Button.closeParenthesis.rawValue {
                while let top = operatorsStack.peek, top != Button.openParenthesis.rawValue {
                    output.append(operatorsStack.pop()!)
                }
                _ = operatorsStack.pop() // Remove "(" from stack
            } else {
                while let top = operatorsStack.peek,
                      let topOp = Button(rawValue: top),
                      let currentOp = Button(rawValue: element),
                      getOperatorPriority(operatorInput: topOp) >= getOperatorPriority(operatorInput: currentOp) {
                    output.append(operatorsStack.pop()!)
                }
                operatorsStack.push(element)
            }
        }
        
        // Pop remaining operators
        while !operatorsStack.isEmpty {
            output.append(operatorsStack.pop()!)
        }
        
        return output
    }
    
    func calculateRPN(_ rpnExpression: [String]) -> Double {
        var stack: Stack<Double> = Stack<Double>()
        
        for token in rpnExpression {
            if let numberValue = Double(token) {
                stack.push(numberValue)
            } else {
                guard let rightOperand = stack.pop(), let leftOperand = stack.pop() else {
                    print("Invalid RPN expression: ", rpnExpression)
                    return Double.nan
                }
                
                switch token {
                case Button.add.rawValue:
                    stack.push(leftOperand + rightOperand)
                case Button.subtract.rawValue:
                    stack.push(leftOperand - rightOperand)
                case Button.multiply.rawValue:
                    stack.push(leftOperand * rightOperand)
                case Button.divide.rawValue:
                    guard rightOperand != 0 else {
                        print("Division by zero is not allowed")
                        return Double.nan
                    }
                    stack.push(leftOperand / rightOperand)
                default:
                    print("Invalid RPN expression: ", rpnExpression)
                    return Double.nan
                }
            }
        }
        
        return stack.pop() ?? 0
    }
    
    private func getOperatorPriority(operatorInput: Button) -> Int {
        switch operatorInput {
        case .add, .subtract:
            return 1
        case .multiply, .divide:
            return 2
        default:
            return 0
        }
    }
}
