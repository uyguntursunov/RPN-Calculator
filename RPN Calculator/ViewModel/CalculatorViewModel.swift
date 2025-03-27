//
//  CalculatorViewModel.swift
//  RPN Calculator
//
//  Created by Uyg'un Tursunov on 21/03/25.
//

import Foundation

protocol CalculatorViewModelProtocol {
    var expressionDidChange: (([String]) -> Void)? { get set }
    var calculatorStateDidChange: ((CalculatorState) -> Void)? { get set }
    func handleButton(_ button: Button)
}

enum CalculatorState: Equatable {
    case initial
    case enteringElement
    case calculatedResult
}

class CalculatorViewModel: CalculatorViewModelProtocol {
    
    private let model: CalculatorModelProtocol
    private let conditions: ConditionsHandlerProtocol
    private let inputProcessor: InputProcessor
    
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
    
    private var state: CalculatorState = .initial {
        didSet {
            updateClearButtonState()
            calculatorStateDidChange?(state)
        }
    }
    
    var expressionDidChange: (([String]) -> Void)?
    var resultDidChange: ((String) -> Void)?
    var calculatorStateDidChange: ((CalculatorState) -> Void)?
    var clearButtonStateDidChange: ((Bool) -> Void)?
    
    private var openParenthesisCount: Int = 0
    private var closeParenthesisCount: Int = 0
    private var isNegative: Bool = false
    
    init(model: CalculatorModelProtocol = CalculatorModel()) {
        self.model = model
        self.conditions = ConditionsHandler()
        self.inputProcessor = InputProcessor(conditions: conditions)
    }
    
    func handleButton(_ button: Button) {
        switch button {
        case .equals:
            calculate()
        default:
            expression = inputProcessor.processInput(button, expression: expression, state: state)
            updateStateAfterInput(button)
        }
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
        state = .calculatedResult
    }
    
    private func updateStateAfterInput(_ button: Button) {
        isNegative = inputProcessor.getIsNegativeNumber()
        
        switch button {
        case .clear:
            state = .initial
        default:
            state = .enteringElement
        }
    }
}

// MARK: Helpers

extension CalculatorViewModel {
    private func updateClearButtonState() {
        clearButtonStateDidChange?(state != .calculatedResult && state != .initial && expression != ["0"])
    }
    
    private func updateElements() {
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
                return inputProcessor.normalizeNumber(element)
            }
            return element
        }
        
        while openParenthesisCount > closeParenthesisCount {
            expression.append(Button.closeParenthesis.rawValue)
        }
    }
}

