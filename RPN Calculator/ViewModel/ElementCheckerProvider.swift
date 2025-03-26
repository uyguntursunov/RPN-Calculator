//
//  ExpressionCheckerProvider.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 25/03/25.
//

import Foundation

enum CheckType {
    case isZero
    case isDecimal
    case isOperator
    case isInvalidState
    case isInitialDecimal
    case isExpressionEmpty
    case isOpenParanthesis
    case isCloseParanthesis
    case isInitialExpression
    case isHighPriorityOperator
    case isNumber(String)
    case isSubtract(String)
    case isNegative(String)
    case hasNumericTail(String)
}

protocol ElementCheckerProtocol {
    func checkElement(_ condition: CheckType, expression: [String]) -> Bool
}

struct ElmentCheckerProvider: ElementCheckerProtocol {
    func checkElement(_ condition: CheckType, expression: [String]) -> Bool {
        var lastElement = expression.last ?? ""
        
        switch condition {
            
        case .isZero:
            return lastElement == "0"
            
        case .isDecimal:
            return lastElement.contains(".")
            
        case .isOperator:
            return isOperator()
            
        case .isInvalidState:
            return lastElement == Errors.undefined.rawValue
            
        case .isInitialDecimal:
            return lastElement == "0."
            
        case .isExpressionEmpty:
            return expression.isEmpty
            
        case .isOpenParanthesis:
            return lastElement == Button.openParenthesis.rawValue
            
        case .isCloseParanthesis:
            return lastElement == Button.closeParenthesis.rawValue
            
        case .isInitialExpression:
            return expression == ["0"]
            
        case .isHighPriorityOperator:
            return isHighPriorityOperator()
            
        case .isNumber(let element):
            return Double(element) != nil
            
        case .isSubtract(let element):
            return element == Button.subtract.rawValue
            
        case .isNegative(let element):
            return element.starts(with: "-")
            
        case .hasNumericTail(let element):
            return Double(element.dropFirst()) != nil
        }
        
        func isOperator() -> Bool {
            switch Button(rawValue: lastElement) {
            case .add, .subtract, .multiply, .divide:
                return true
            default:
                return false
            }
        }
        
        func isHighPriorityOperator() -> Bool {
            switch Button(rawValue: lastElement) {
            case .multiply, .divide:
                return true
            default:
                return false
            }
        }
    }
}
