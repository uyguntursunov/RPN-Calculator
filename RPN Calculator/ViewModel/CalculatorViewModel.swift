//
//  CalculatorViewModel.swift
//  RPN Calculator
//
//  Created by Uyg'un Tursunov on 21/03/25.
//

import Foundation

protocol CalculatorViewModelConditions {
    func isZero() -> Bool
    func isDecimal() -> Bool
    func isOperator() -> Bool
    func isInvalidState() -> Bool
    func isInitialDecimal() -> Bool
    func isExpressionEmpty() -> Bool
    func isOpenParanthesis() -> Bool
    func isCloseParanthesis() -> Bool
    func isInitialExpression() -> Bool
    func isHighPriorityOperator() -> Bool
    func isNumber(_ element: String) -> Bool
    func isSubtract(_ element: String) -> Bool
    func isNegative(_ element: String) -> Bool
    func hasNumericTail(_ element: String) -> Bool
}

class CalculatorViewModel {
    private let model: CalculatorModelProtocol
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
        let conditions = (
            isRecalculation: isRecalculation || isInitialExpression(),
            isNegativeContext: isSubtract(lastElement) && isNegativeNumber,
            isNumberAppendable: isInitialDecimal() || isNumber(lastElement) || (isNegative(lastElement) && hasNumericTail(lastElement)),
            isCloseParenthesis: isCloseParanthesis()
        )
        
        switch conditions {
        case (true, _, _, _):
            expression = [num.rawValue]
            
        case (_, true, _, _):
            expression = expression.dropLast() + ["-\(num.rawValue)"]
            
        case (_, _, true, _):
            let currentNumber = lastElement + num.rawValue
            let normalizedNumber = normalizeNumber(currentNumber)
            expression[expression.count - 1] = normalizedNumber
            
        case (_, _, _, true):
            expression += [Button.multiply.rawValue, num.rawValue]
            
        case (_, _, _, _):
            expression.append(num.rawValue)
        }
        
        isRecalculation = false
    }
    
    private func appendOperator(_ op: Button) {
        guard !isInvalidState() else { return }
        
        let conditions = (
            isNegativeCase: isExpressionEmpty() || isOpenParanthesis() || isHighPriorityOperator(),
            isSubtractOperator: isSubtract(op.rawValue),
            isLastOperator: isOperator(),
            isLastSubtract: isSubtract(lastElement),
            isLastOpenParens: isOpenParanthesis()
        )
        
        switch conditions {
        case (true, true, _, _, _):
            expression.append(op.rawValue)
            isNegativeNumber = true
            return
            
        case (_, false, _, _, true):
            return
            
        case (_, false, _, true, _):
            expression.removeLast()
            return
            
        case (_, _, true, _, _):
            expression = expression.dropLast() + [op.rawValue]
            
        case (_, _, _, _, _):
            expression += [op.rawValue]
        }
        
        isRecalculation = false
        isNegativeNumber = false
    }
    
    private func appendParenthesis(_ parenthesis: Button) {
        let conditions = (
            isRecalculation: isRecalculation || isInitialExpression(),
            isNumberOrCloseParens: isNumber(lastElement) || isCloseParanthesis(),
            canClose: canCloseParenthesis()
        )
        
        switch (parenthesis, conditions) {
        case (.openParenthesis, (true, _, _)):
            expression = [parenthesis.rawValue]
            
        case (.openParenthesis, (_, true, _)):
            expression += [Button.multiply.rawValue, parenthesis.rawValue]
            
        case (.openParenthesis, (_, _, _)):
            expression += [parenthesis.rawValue]
            
        case (.closeParenthesis, (_, _, true)):
            expression += [parenthesis.rawValue]
            
        case (.closeParenthesis, (_, _, false)):
            break
            
        default:
            break
        }
        
        if parenthesis == .openParenthesis {
            isRecalculation = false
        }
    }
    
    private func appendDecimal() {
        guard !isInvalidState() else { return }
        
        let conditions = (
            hasDecimal: isDecimal(),
            isOperatorOrOpenParens: isOperator() || isOpenParanthesis(),
            isRecalculation: isRecalculation
        )
        
        switch conditions {
        case (true, _, _):
            break
            
        case (_, true, _):
            expression.append("0.")
            
        case (_, _, true):
            expression = ["0."]
            
        case (_, _, _):
            expression[expression.count - 1] += "."
        }
        
        isRecalculation = false
    }
    
    private func removeLast() {
        let conditions = (
            isEmptyOrZero: isExpressionEmpty() || isInitialExpression(),
            isInvalid: isInvalidState(),
            isMultiDigit: lastElement.count > 1
        )
        
        switch conditions {
        case (true, _, _):
            break
            
        case (_, true, _):
            expression = []
            
        case (_, _, true):
            expression = expression.dropLast() + [String(lastElement.dropLast())]
            
        case (_, _, _):
            expression = expression.dropLast()
            switch expression.isEmpty {
            case true:
                expression = ["0"]
            case false:
                break
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
    
    private func canCloseParenthesis() -> Bool {
        openParenthesisCount > closeParenthesisCount && !isZero() && !isOpenParanthesis() && !isOperator()
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
        while isOperator() || isOpenParanthesis() {
            expression.removeLast()
            if expression.isEmpty {
                expression = ["0"]
                return
            }
        }
        
        expression = expression.map { element in
            if isNumber(element) || (isNegative(element) && hasNumericTail(element)) {
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

// MARK: CalculatorViewModel Conditions

extension CalculatorViewModel: CalculatorViewModelConditions {
    func isHighPriorityOperator() -> Bool {
        switch Button(rawValue: lastElement) {
        case .multiply, .divide:
            return true
        default:
            return false
        }
    }
    
    func isOperator() -> Bool {
        switch Button(rawValue: lastElement) {
        case .add, .subtract, .multiply, .divide:
            return true
        default:
            return false
        }
    }
    
    func isInitialExpression() -> Bool {
        expression == ["0"]
    }
    
    func isNumber(_ element: String) -> Bool {
        Double(element) != nil
    }
    
    func isInitialDecimal() -> Bool {
        lastElement == "0."
    }
    
    func isNegative(_ element: String) -> Bool {
        element.starts(with: "-")
    }
    
    func isCloseParanthesis() -> Bool {
        lastElement == Button.closeParenthesis.rawValue
    }
    
    func isOpenParanthesis() -> Bool {
        lastElement == Button.openParenthesis.rawValue
    }
    
    func isZero() -> Bool {
        lastElement == "0"
    }
    
    func isDecimal() -> Bool {
        return lastElement.contains(".")
    }
    
    func isSubtract(_ element: String) -> Bool {
        element == Button.subtract.rawValue
    }
    
    func isExpressionEmpty() -> Bool {
        expression.isEmpty
    }
    
    func isInvalidState() -> Bool {
        return expression.first == Errors.undefined.rawValue
    }
    
    func hasNumericTail(_ element: String) -> Bool {
        Double(element.dropFirst()) != nil
    }
}
