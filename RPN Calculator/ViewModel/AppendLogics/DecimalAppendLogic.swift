//
//  DecimalAppendLogic.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 26/03/25.
//

import Foundation

struct DecimalAppendLogic {
    private let conditions: CalculatorViewModelConditions
    
    init(conditions: CalculatorViewModelConditions) {
        self.conditions = conditions
    }
    
    // Enum defining possible actions for appending a decimal
    enum Action {
        case noChange
        case appendZeroDecimal
        case startNewDecimal
        case appendDecimalToLast
    }
    
    // Determine the action based on conditions
    func determineAction(for expression: [String], isRecalculation: Bool) -> Action {
        if conditions.isInvalidState(expression) || conditions.isDecimal(expression) {
            return .noChange
        } else if conditions.isOperator(expression) || conditions.isOpenParanthesis(expression) {
            return .appendZeroDecimal
        } else if isRecalculation {
            return .startNewDecimal
        } else {
            return .appendDecimalToLast
        }
    }
}
