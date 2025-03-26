//
//  NumberAppendChecker.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 26/03/25.
//

struct NumberAppendLogic {
    private let conditions: CalculatorViewModelConditions
    
    // Initialize with the conditions handler
    init(conditions: CalculatorViewModelConditions) {
        self.conditions = conditions
    }
    
    // Enum defining possible actions for appending a number
    enum Action {
        case startNewExpression
        case replaceLastWithNegativeNumber
        case appendDigitToLast
        case implicitlyMultiplyAndAppend
        case appendNewNumber
    }
    
    // Determine the action based on conditions
    func determineAction(for expression: [String], with button: Button, isRecalculation: Bool, isNegativeNumber: Bool) -> Action {
        let lastElement = expression.last ?? ""
        
        if isRecalculation || conditions.isInitialExpression(expression) {
            return .startNewExpression
        } else if conditions.isSubtract(element: lastElement) && isNegativeNumber {
            return .replaceLastWithNegativeNumber
        } else if conditions.isInitialDecimal(expression) ||
                  conditions.isNumber(element: lastElement) ||
                  (conditions.isNegative(element: lastElement) && conditions.hasNumericTail(element: lastElement)) {
            return .appendDigitToLast
        } else if conditions.isCloseParanthesis(expression) {
            return .implicitlyMultiplyAndAppend
        } else {
            return .appendNewNumber
        }
    }
}
