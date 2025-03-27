//
//  NumberAppendChecker.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 26/03/25.
//

struct NumberAppendLogic {
    private let conditions: CalculatorViewModelConditions
    
    init(conditions: CalculatorViewModelConditions) {
        self.conditions = conditions
    }
    
    func determineAction(for expression: [String], with button: Button, isRecalculation: Bool, isNegativeNumber: Bool) -> Action {
        let lastElement = expression.last ?? ""
        
        if isRecalculation || conditions.isInitialExpression(expression) {
            return .startNewExpression
        } else if conditions.isSubtract(lastElement) && isNegativeNumber {
            return .replaceLastWithNegativeNumber
        } else if conditions.isInitialDecimal(expression) ||
                    conditions.isNumber(lastElement) ||
                    (conditions.isNegative(lastElement) && conditions.hasNumericTail(lastElement)) {
            return .appendDigitToLast
        } else if conditions.isCloseParanthesis(expression) {
            return .implicitlyMultiplyAndAppend
        } else {
            return .appendNewNumber
        }
    }
    
    enum Action {
        case startNewExpression
        case replaceLastWithNegativeNumber
        case appendDigitToLast
        case implicitlyMultiplyAndAppend
        case appendNewNumber
    }
}
