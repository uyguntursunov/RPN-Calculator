//
//  OperatorAppendLogic.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 26/03/25.
//

import Foundation

struct OperatorAppendLogic {
    private let conditions: CalculatorViewModelConditions
    
    init(conditions: CalculatorViewModelConditions) {
        self.conditions = conditions
    }
    
    // Enum defining possible actions for appending an operator
    enum Action {
        case appendOperatorAndSetNegative
        case noChange
        case removeLast
        case replaceLastWithOperator
        case appendOperator
    }
    
    // Determine the action based on conditions
    func determineAction(for expression: [String], with button: Button, isNegativeNumber: Bool) -> Action {
        if conditions.isInvalidState(expression) {
            return .noChange
        }
        
        let lastElement = expression.last ?? ""
        let isNegativeCase = conditions.isExpressionEmpty(expression) ||
                            conditions.isOpenParanthesis(expression) ||
                            conditions.isHighPriorityOperator(expression)
        let isSubtractOperator = conditions.isSubtract(button.rawValue)
        let isLastOperator = conditions.isOperator(expression)
        let isLastSubtract = conditions.isSubtract(lastElement)
        let isLastOpenParens = conditions.isOpenParanthesis(expression)
        
        if isNegativeCase && isSubtractOperator {
            return .appendOperatorAndSetNegative
        } else if !isSubtractOperator && isLastOpenParens {
            return .noChange
        } else if !isSubtractOperator && isLastSubtract {
            return .removeLast
        } else if isLastOperator {
            return .replaceLastWithOperator
        } else {
            return .appendOperator
        }
    }
}
