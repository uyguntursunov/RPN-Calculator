//
//  RemoveLastLogic.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 26/03/25.
//

import Foundation

struct RemoveLastLogic {
    private let conditions: ConditionsHandlerProtocol
    
    init(conditions: ConditionsHandlerProtocol) {
        self.conditions = conditions
    }
    
    func determineAction(for expression: [String]) -> Action {
        let lastElement = expression.last ?? ""
        
        if conditions.isExpressionEmpty(expression) || conditions.isInitialExpression(expression) {
            return .noChange
        } else if conditions.isInvalidState(expression) {
            return .clearExpression
        } else if lastElement.count > 1 {
            return .trimLastElement
        } else {
            return .removeLastAndResetToZero
        }
    }
    
    enum Action {
        case noChange
        case clearExpression
        case trimLastElement
        case removeLastAndResetToZero
    }
}
