//
//  CalculatorViewModel.swift
//  RPN Calculator
//
//  Created by Uyg'un Tursunov on 21/03/25.
//

import Foundation

class CalculatorViewModel {
    private let model: CalculatorModelProtocol
    private let conditions: CalculatorViewModelConditions
    private let numberAppendLogic: NumberAppendLogic
    private let operatorAppendLogic: OperatorAppendLogic
    private let parenthesisAppendLogic: ParenthesisAppendLogic
    private let decimalAppendLogic: DecimalAppendLogic
    private let removeLastLogic: RemoveLastLogic
    
    private var isNegativeNumber: Bool = false
    private var isRecalculation: Bool = false
    private var isFinalResult: Bool = false
    private var lastElement: String = ""
    private var openParenthesisCount: Int = 0
    private var closeParenthesisCount: Int = 0
    
    private var expression: [String] = ["0"] {
        didSet {
            print("Expression:", expression)
            updateElements()
            expressionDidChange?(expression)
        }
    }
    
    private var result: Double = 0.0 {
        didSet { resultDidChange?(String(result)) }
    }
    
    var expressionDidChange: (([String]) -> Void)?
    var resultDidChange: ((String) -> Void)?
    var clearButtonStateDidChange: ((Bool) -> Void)?
    
    init(model: CalculatorModelProtocol = CalculatorModel(expression: ["0"], result: 0.0)) {
        self.conditions = ConditionsHandler()
        self.numberAppendLogic = NumberAppendLogic(conditions: conditions)
        self.operatorAppendLogic = OperatorAppendLogic(conditions: conditions)
        self.parenthesisAppendLogic = ParenthesisAppendLogic(conditions: conditions)
        self.decimalAppendLogic = DecimalAppendLogic(conditions: conditions)
        self.removeLastLogic = RemoveLastLogic(conditions: conditions)
        self.model = model
    }
    
    func handleButton(_ button: Button) {
        switch button {
        case .equals:
            isFinalResult = true
        default:
            isFinalResult = false
        }
        
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            appendNumber(button)
        case .add, .subtract, .multiply, .divide:
            appendOperator(button)
        case .openParenthesis, .closeParenthesis:
            appendParenthesis(button)
        case .decimalSeparator:
            appendDecimal()
        case .backspace:
            removeLast()
        case .clear:
            clear()
        case .equals:
            calculate()
        default:
            break
        }
        
        updateClearButtonState()
    }
    
    private func calculate() {
        sanitizeExpression()
        guard isValidExpression(expression) else { return }
        let rpn = model.convertToRPN(expression)
        result = model.calculateRPN(rpn)
        
        if result.isNaN {
            expression = [Errors.undefined.rawValue]
        } else {
            expression = [String(result)]
        }
        
        isRecalculation = true
        isNegativeNumber = false
    }
    
    // MARK: Input Handling
    
    private func appendNumber(_ num: Button) {
        let action = numberAppendLogic.determineAction(
            for: expression,
            with: num,
            isRecalculation: isRecalculation,
            isNegativeNumber: isNegativeNumber
        )
        
        switch action {
        case .startNewExpression:
            expression = [num.rawValue]
            
        case .replaceLastWithNegativeNumber:
            expression = expression.dropLast() + ["-\(num.rawValue)"]
            
        case .appendDigitToLast:
            let lastElement = expression.last ?? ""
            let currentNumber = lastElement + num.rawValue
            let normalizedNumber = normalizeNumber(currentNumber)
            expression[expression.count - 1] = normalizedNumber
            
        case .implicitlyMultiplyAndAppend:
            expression += [Button.multiply.rawValue, num.rawValue]
            
        case .appendNewNumber:
            expression.append(num.rawValue)
        }
        
        isRecalculation = false
    }
    
    private func appendOperator(_ op: Button) {
        let action = operatorAppendLogic.determineAction(
            for: expression,
            with: op,
            isNegativeNumber: isNegativeNumber
        )
        
        switch action {
        case .appendOperatorAndSetNegative:
            expression.append(op.rawValue)
            isNegativeNumber = true
        case .noChange:
            break
        case .removeLast:
            expression.removeLast()
        case .replaceLastWithOperator:
            expression = expression.dropLast() + [op.rawValue]
            isRecalculation = false
            isNegativeNumber = false
        case .appendOperator:
            expression.append(op.rawValue)
            isRecalculation = false
            isNegativeNumber = false
        }
    }
    
    private func appendParenthesis(_ parenthesis: Button) {
            let action = parenthesisAppendLogic.determineAction(
                for: expression,
                with: parenthesis,
                isRecalculation: isRecalculation,
                openCount: openParenthesisCount,
                closeCount: closeParenthesisCount
            )
            
            switch action {
            case .startNewOpenParenthesis:
                expression = [parenthesis.rawValue]
                isRecalculation = false
            case .implicitlyMultiplyAndOpen:
                expression += [Button.multiply.rawValue, parenthesis.rawValue]
                isRecalculation = false
            case .appendOpenParenthesis:
                expression.append(parenthesis.rawValue)
                isRecalculation = false
            case .appendCloseParenthesis:
                expression.append(parenthesis.rawValue)
            case .noChange:
                break
            }
        }
    
    private func appendDecimal() {
            let action = decimalAppendLogic.determineAction(
                for: expression,
                isRecalculation: isRecalculation
            )
            
            switch action {
            case .noChange:
                break
            case .appendZeroDecimal:
                expression.append("0.")
            case .startNewDecimal:
                expression = ["0."]
            case .appendDecimalToLast:
                expression[expression.count - 1] += "."
            }
            
            isRecalculation = false
        }
    
    private func removeLast() {
            let action = removeLastLogic.determineAction(for: expression)
            
            switch action {
            case .noChange:
                break
            case .clearExpression:
                expression = []
            case .trimLastElement:
                let lastElement = expression.last ?? ""
                expression = expression.dropLast() + [String(lastElement.dropLast())]
            case .removeLastAndResetToZero:
                expression = expression.dropLast()
                if expression.isEmpty {
                    expression = ["0"]
                }
            }
        }
    
    private func clear() {
        expression = ["0"]
        result = 0.0
    }
}

// MARK: Helpers

extension CalculatorViewModel {
    private func updateClearButtonState() {
        clearButtonStateDidChange?(!isRecalculation && expression != ["0"])
    }
    
    private func updateElements() {
        lastElement = expression.last ?? ""
        openParenthesisCount = expression.filter { $0 == Button.openParenthesis.rawValue }.count
        closeParenthesisCount = expression.filter { $0 == Button.closeParenthesis.rawValue }.count
    }
    
    private func isValidExpression(_ expression: [String]) -> Bool {
        let operands = expression.filter { Double($0) != nil }.count
        let operators = expression.filter { Button(rawValue: $0)?.isOperator == true }.count
        
        return operands > operators && openParenthesisCount == closeParenthesisCount && operands > 1
    }
    
    private func sanitizeExpression() {
        while conditions.isOperator(expression) || conditions.isOpenParanthesis(expression) {
            expression.removeLast()
            if expression.isEmpty {
                expression = ["0"]
                return
            }
        }
        
        expression = expression.map { element in
            if conditions.isNumber(element) || (conditions.isNegative(element) && conditions.hasNumericTail(element)) {
                return normalizeNumber(element)
            }
            return element
        }
        
        while openParenthesisCount > closeParenthesisCount {
            expression.append(Button.closeParenthesis.rawValue)
        }
    }
    
    private func normalizeNumber(_ number: String) -> String {
        guard !number.isEmpty else { return "0" }
        
        let isNegative = number.starts(with: "-")
        let absoluteNumber = isNegative ? String(number.dropFirst()) : number
        
        // Split into integer and decimal parts
        let components = absoluteNumber.split(separator: ".", maxSplits: 1)
        let integerPart = components.first.map { String($0) } ?? ""
        let decimalPart = components.count > 1 ? String(components[1]) : ""
        
        // Remove leading zeros from integer part, but keep "0" if no other digits
        let trimmedInteger = integerPart.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
        let normalizedInteger = trimmedInteger.isEmpty ? "0" : trimmedInteger
        
        // Reconstruct the number
        let result = decimalPart.isEmpty ? normalizedInteger : "\(normalizedInteger).\(decimalPart)"
        
        return isNegative ? "-\(result)" : result
    }
}

