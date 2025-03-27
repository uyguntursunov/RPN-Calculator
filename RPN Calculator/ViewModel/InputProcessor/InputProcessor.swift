//
//  InputProcessor.swift
//  RPN Calculator
//
//  Created by Uyg'un Tursunov on 27/03/25.
//

import Foundation

class InputProcessor {
    private let conditions: ConditionsHandlerProtocol
    private let numberAppendLogic: NumberAppendLogic
    private let operatorAppendLogic: OperatorAppendLogic
    private let decimalAppendLogic: DecimalAppendLogic
    private let parenthesisAppendLogic: ParenthesisAppendLogic
    private let removeLastLogic: RemoveLastLogic
    
    init(conditions: ConditionsHandlerProtocol) {
        self.conditions = conditions
        self.numberAppendLogic = NumberAppendLogic(conditions: conditions)
        self.operatorAppendLogic = OperatorAppendLogic(conditions: conditions)
        self.decimalAppendLogic = DecimalAppendLogic(conditions: conditions)
        self.parenthesisAppendLogic = ParenthesisAppendLogic(conditions: conditions)
        self.removeLastLogic = RemoveLastLogic(conditions: conditions)
    }
    
    private var isNegativeNumber: Bool = false
    
    func getIsNegativeNumber() -> Bool {
        return isNegativeNumber
    }
    
    func processInput(_ button: Button,
                      expression: [String],
                      state: CalculatorState) -> [String] {
        
        var newExpression = expression
        let openParenthesisCount = expression.filter { $0 == Button.openParenthesis.rawValue }.count
        let closeParenthesisCount = expression.filter { $0 == Button.closeParenthesis.rawValue }.count
        
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            
            newExpression = appendNumber(button, expression: expression, state: state)
            
        case .add, .subtract, .multiply, .divide:
            newExpression = appendOperator(button, expression: expression, state: state)
            
        case .openParenthesis, .closeParenthesis:
            newExpression = appendParenthesis(button,
                                              expression: expression,
                                              state: state,
                                              openCount: openParenthesisCount,
                                              closeCount: closeParenthesisCount)
            
        case .decimalSeparator:
            newExpression = appendDecimal(expression: expression, state: state)
            
        case .backspace:
            newExpression = removeLast(expression: expression)
            
        case .clear:
            newExpression = ["0"]
            
        case .equals:
            newExpression = expression
            
        default:
            break
        }
        
        return newExpression
    }
    
    // MARK: - Number Handling
    private func appendNumber(_ num: Button,
                              expression: [String],
                              state: CalculatorState) -> [String] {
        let isRecalculation = state == .calculatedResult
        let action = numberAppendLogic.determineAction(for: expression,
                                                       with: num,
                                                       isRecalculation: isRecalculation,
                                                       isNegativeNumber: isNegativeNumber)
        var newExpression = expression
        
        switch action {
        case .startNewExpression:
            return [num.rawValue]
            
        case .replaceLastWithNegativeNumber:
            return expression.dropLast() + ["-\(num.rawValue)"]
            
        case .appendDigitToLast:
            let lastElement = expression.last ?? ""
            let currentNumber = lastElement + num.rawValue
            let normalizedNumber = normalizeNumber(currentNumber)
            newExpression[expression.count - 1] = normalizedNumber
            return newExpression
            
        case .implicitlyMultiplyAndAppend:
            return expression + [Button.multiply.rawValue, num.rawValue]
            
        case .appendNewNumber:
            return expression + [num.rawValue]
        }
    }
    
    // MARK: - Operator Handling
    private func appendOperator(_ op: Button,
                                expression: [String],
                                state: CalculatorState) -> [String] {
        let action = operatorAppendLogic.determineAction(for: expression,
                                                         with: op,
                                                         isNegativeNumber: isNegativeNumber)
        
        switch action {
        case .appendOperatorAndSetNegative:
            isNegativeNumber = true
            return expression + [op.rawValue]
        case .noChange:
            return expression
        case .removeLast:
            return expression.dropLast()
        case .replaceLastWithOperator:
            isNegativeNumber = false
            return expression.dropLast() + [op.rawValue]
        case .appendOperator:
            isNegativeNumber = false
            return expression + [op.rawValue]
        }
    }
    
    // MARK: - Parenthesis Handling
    private func appendParenthesis(_ parenthesis: Button,
                                   expression: [String],
                                   state: CalculatorState,
                                   openCount: Int,
                                   closeCount: Int) -> [String] {
        let isRecalculation = state == .calculatedResult
        let action = parenthesisAppendLogic.determineAction(for: expression,
                                                            with: parenthesis,
                                                            isRecalculation: isRecalculation,
                                                            openCount: openCount,
                                                            closeCount: closeCount)
        
        switch action {
        case .startNewOpenParenthesis:
            return [parenthesis.rawValue]
        case .implicitlyMultiplyAndOpen:
            return expression + [Button.multiply.rawValue, parenthesis.rawValue]
        case .appendOpenParenthesis:
            return expression + [parenthesis.rawValue]
        case .appendCloseParenthesis:
            return expression + [parenthesis.rawValue]
        case .noChange:
            return expression
        }
    }
    
    // MARK: - Decimal Handling
    private func appendDecimal(expression: [String], state: CalculatorState) -> [String] {
        let isRecalculation = state == .calculatedResult
        let action = decimalAppendLogic.determineAction(for: expression, isRecalculation: isRecalculation)
        var newExpression = expression
        
        switch action {
        case .noChange:
            return expression
        case .appendZeroDecimal:
            return expression + ["0."]
        case .startNewDecimal:
            return ["0."]
        case .appendDecimalToLast:
            newExpression[expression.count - 1] += "."
            return newExpression
        }
    }
    
    // MARK: - Remove Last Handling
    private func removeLast(expression: [String]) -> [String] {
        let action = removeLastLogic.determineAction(for: expression)
        var newExpression = expression
        
        switch action {
        case .noChange:
            return expression
        case .clearExpression:
            return ["0"]
        case .trimLastElement:
            let lastElement = expression.last ?? ""
            return expression.dropLast() + [String(lastElement.dropLast())]
        case .removeLastAndResetToZero:
            newExpression = expression.dropLast()
            if newExpression.isEmpty {
                return ["0"]
            }
            return newExpression
        }
    }
    
    // MARK: - Helper
    func normalizeNumber(_ number: String) -> String {
        guard !number.isEmpty else { return "0" }
        let absoluteNumber = conditions.isNegative(number) ? String(number.dropFirst()) : number
        let components = absoluteNumber.split(separator: ".", maxSplits: 1)
        let integerPart = components.first.map { String($0) } ?? ""
        let decimalPart = components.count > 1 ? String(components[1]) : ""
        let trimmedInteger = integerPart.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
        let normalizedInteger = trimmedInteger.isEmpty ? "0" : trimmedInteger
        let result = decimalPart.isEmpty ? normalizedInteger : "\(normalizedInteger).\(decimalPart)"
        return conditions.isNegative(number) ? "-\(result)" : result
    }
}
