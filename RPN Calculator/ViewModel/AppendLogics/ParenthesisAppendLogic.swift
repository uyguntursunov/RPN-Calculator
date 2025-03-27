//
//  ParenthesisAppendLogic.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 26/03/25.
//

import Foundation

struct ParenthesisAppendLogic {
    private let conditions: ConditionsHandlerProtocol
    
    init(conditions: ConditionsHandlerProtocol) {
        self.conditions = conditions
    }

    func determineAction(for expression: [String], with parenthesis: Button, isRecalculation: Bool, openCount: Int, closeCount: Int) -> Action {
        let lastElement = expression.last ?? ""
        let canClose = openCount > closeCount &&
                       !conditions.isZero(expression) &&
                       !conditions.isOpenParanthesis(expression) &&
                       !conditions.isOperator(expression)
        
        switch parenthesis {
        case .openParenthesis:
            if isRecalculation || conditions.isInitialExpression(expression) {
                return .startNewOpenParenthesis
            } else if conditions.isNumber(lastElement) || conditions.isCloseParanthesis(expression) {
                return .implicitlyMultiplyAndOpen
            } else {
                return .appendOpenParenthesis
            }
        case .closeParenthesis:
            if canClose {
                return .appendCloseParenthesis
            } else {
                return .noChange
            }
        default:
            return .noChange
        }
    }
    
    enum Action {
        case startNewOpenParenthesis
        case implicitlyMultiplyAndOpen
        case appendOpenParenthesis
        case appendCloseParenthesis
        case noChange
    }
}
