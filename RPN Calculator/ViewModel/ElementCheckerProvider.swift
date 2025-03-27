//
//  ElementCheckerProvider.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 25/03/25.
//

import Foundation

protocol CalculatorViewModelConditions {
    func isZero(_ expression: [String]) -> Bool
    func isDecimal(_ expression: [String]) -> Bool
    func isOperator(_ expression: [String]) -> Bool
    func isInvalidState(_ expression: [String]) -> Bool
    func isInitialDecimal(_ expression: [String]) -> Bool
    func isExpressionEmpty(_ expression: [String]) -> Bool
    func isOpenParanthesis(_ expression: [String]) -> Bool
    func isCloseParanthesis(_ expression: [String]) -> Bool
    func isInitialExpression(_ expression: [String]) -> Bool
    func isHighPriorityOperator(_ expression: [String]) -> Bool
    func isNumber(_ element: String) -> Bool
    func isSubtract(_ element: String) -> Bool
    func isNegative(_ element: String) -> Bool
    func hasNumericTail(_ element: String) -> Bool
}

struct ConditionsHandler: CalculatorViewModelConditions {
    func isZero(_ expression: [String]) -> Bool {
        expression.last == "0"
    }
    
    func isDecimal(_ expression: [String]) -> Bool {
        expression.last?.contains(".") ?? false
    }
    
    func isOperator(_ expression: [String]) -> Bool {
        guard let last = expression.last else { return false }
        switch Button(rawValue: last) {
        case .add, .subtract, .multiply, .divide:
            return true
        default:
            return false
        }
    }
    
    func isInvalidState(_ expression: [String]) -> Bool {
        expression.first == Errors.undefined.rawValue
    }
    
    func isInitialDecimal(_ expression: [String]) -> Bool {
        expression.last == "0."
    }
    
    func isExpressionEmpty(_ expression: [String]) -> Bool {
        expression.isEmpty
    }
    
    func isOpenParanthesis(_ expression: [String]) -> Bool {
        expression.last == Button.openParenthesis.rawValue
    }
    
    func isCloseParanthesis(_ expression: [String]) -> Bool {
        expression.last == Button.closeParenthesis.rawValue
    }
    
    func isInitialExpression(_ expression: [String]) -> Bool {
        expression == ["0"]
    }
    
    func isHighPriorityOperator(_ expression: [String]) -> Bool {
        guard let last = expression.last else { return false }
        switch Button(rawValue: last) {
        case .multiply, .divide:
            return true
        default:
            return false
        }
    }
    
    func isNumber(_ element: String) -> Bool {
        Double(element) != nil
    }
    
    func isSubtract(_ element: String) -> Bool {
        element == Button.subtract.rawValue
    }
    
    func isNegative(_ element: String) -> Bool {
        element.starts(with: "-")
    }
    
    func hasNumericTail(_ element: String) -> Bool {
        guard element.count > 1 else { return false }
        return Double(element.dropFirst()) != nil
    }
}


