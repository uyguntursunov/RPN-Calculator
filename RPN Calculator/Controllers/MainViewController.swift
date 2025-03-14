//
//  MainViewController.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 07/03/25.
//

import UIKit

protocol MainViewControllerDelegate: AnyObject {
    func didTapNumberButton(_ num: Button)
    func didTapOperatorButton(_ op: Button)
    func didTapBackspaceButton()
    func didTapDecimalButton()
    func didTapOpenParenthesisButton()
    func didTapCloseParenthesisButton()
    func didTapEqualsButton()
    func didTapClearButton()
    func didTapMicButton()
}

class MainViewController: UIViewController {
    
    private let buttonsStackView = ButtonsStackView()
    private let labelScrollView = LabelScrollView()
    
    private lazy var speechController: SpeechController = {
        let speechController = SpeechController()
        speechController.delegate = self
        return speechController
    }()
    
    var calculations: [CalculationEntity] = []
    
    private var isNegativeNumber: Bool = false
    private var rpnExpression: [String] = []
    private var firstElement: String = ""
    private var lastElement: String = ""
    private var numOfOperands: Int = 0
    private var numOfOperators: Int = 0
    private var openParenthesisCount: Int = 0
    private var closeParenthesisCount: Int = 0
    private var isRecalculation: Bool = false
    private var isRecording: Bool = false
    
    var calculator: Calculator = Calculator(expression: [], result: 0.0)
    
    private var expression: [String] = ["0"] {
        didSet {
            print("Expression: \(expression)")
            updateElementsCount()
            updateFirstElement()
            updateLastElement()
            updateClearButton(isBackspace: expression != ["0"])
            updateDisplay()
        }
    }
    
    private lazy var textAndButton: Dictionary<String, String> = {
        return ["zero": "0",
                "one": "1",
                "two": "2",
                "three": "3",
                "four": "4",
                "five": "5",
                "six": "6",
                "seven": "7",
                "eight": "8",
                "nine": "9",
                "ten": "10",
                "plus": "+",
                "minus": "-",
                "equals": "=",
                "0": "0",
                "1": "1",
                "2": "2",
                "3": "3",
                "4": "4",
                "5": "5",
                "6": "6",
                "7": "7",
                "8": "8",
                "9": "9",
                "10": "10",]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
//        fetchCalculations()
    }
    
    private func configureLayout() {
        view.backgroundColor = .systemBackground
        addSubviews()
        
        buttonsStackView.delegate = self
        
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let topPadding: CGFloat = 75.0
        let padding: CGFloat = 10.0
        
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -topPadding),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
        
        let labelBottomSpacing: CGFloat = 20.0
        
        NSLayoutConstraint.activate([
            labelScrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -labelBottomSpacing),
            labelScrollView.leadingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor),
            labelScrollView.trailingAnchor.constraint(equalTo: buttonsStackView.trailingAnchor),
            labelScrollView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func addSubviews() {
        view.addSubview(buttonsStackView)
        view.addSubview(labelScrollView)
    }
}

// MARK: MainViewControllerDelegate Button Actions

extension MainViewController: MainViewControllerDelegate {
    func didTapNumberButton(_ num: Button) {
        guard num.isNumber, firstElement != Errors.undefined.rawValue else { return }
        
        if isRecalculation || expression == ["0"] {
            expression = [num.rawValue]
        } else if lastElement == Button.openParenthesis.rawValue || (lastElement == Button.subtract.rawValue && isNegativeNumber) {
            // Combine with "-" if it's part of a negative number
            if lastElement == Button.subtract.rawValue {
                expression.removeLast() // Remove standalone "-"
                expression.append("-\(num.rawValue)")
            } else {
                expression.append(num.rawValue)
            }
        } else if Double(lastElement) != nil || (lastElement.starts(with: "-") && Double(lastElement.dropFirst()) != nil) {
            let currentNumber = lastElement + num.rawValue
            let normalizedNumber = normalizeNumber(currentNumber)
            expression[expression.count - 1] = normalizedNumber
        } else if lastElement == Button.closeParenthesis.rawValue {
            expression += [Button.multiply.rawValue, num.rawValue]
        } else {
            expression.append(num.rawValue)
        }
        
        isRecalculation = false
        isNegativeNumber = false // Reset after number is entered
    }
    
    func didTapOperatorButton(_ op: Button) {
        guard op.isOperator, firstElement != Errors.undefined.rawValue else { return }
        
        if op == .subtract && (expression.isEmpty || lastElement == Button.openParenthesis.rawValue || Button(rawValue: lastElement)?.isOperator == true) {
            // Treat "-" as part of a negative number after "(", at start, or after another operator
            expression.append(op.rawValue)
            isNegativeNumber = true
            return
        }
        
        if openParenthesisCount > 0, op != Button.subtract {
            if lastElement == Button.subtract.rawValue {
                expression.removeLast()
                return
            } else if lastElement == Button.openParenthesis.rawValue {
                return
            }
        }
        
        if Button(rawValue: lastElement)?.isOperator == true {
            expression.removeLast() // Replace previous operator
        }
        
        expression.append(op.rawValue)
        isRecalculation = false
        isNegativeNumber = false
    }
    
    func didTapOpenParenthesisButton() {
        if isRecalculation || expression == ["0"] {
            expression = []
        } else if Double(lastElement) != nil || lastElement == Button.closeParenthesis.rawValue {
            expression.append(Button.multiply.rawValue)
        }
        // Add an opening parenthesis
        expression.append(Button.openParenthesis.rawValue)
        isRecalculation = false
    }
    
    func didTapCloseParenthesisButton() {
        guard let button = Button(rawValue: lastElement) else { return }
        
        if lastElement == Button.zero.rawValue || lastElement == Button.openParenthesis.rawValue || button.isOperator {
            return
        }
        if openParenthesisCount > closeParenthesisCount {
            expression.append(Button.closeParenthesis.rawValue)
        }
        updateDisplay()
    }
    
    func didTapDecimalButton() {
        if firstElement == Errors.undefined.rawValue { return }
        if lastElement.contains(".") {
            return
        } else if Button(rawValue: lastElement)?.isOperator == true || lastElement == Button.openParenthesis.rawValue {
            expression.append("0.")
        } else if isRecalculation {
            expression = ["0."]
        } else {
            expression[expression.count - 1] += "."
        }
    }
    
    func didTapEqualsButton() {
        guard firstElement != Errors.undefined.rawValue,
              expression.count > 1,
              numOfOperands > 1 else { return }
        
        // Clean up trailing operators or parentheses
        while Button(rawValue: lastElement)?.isOperator == true || lastElement == Button.openParenthesis.rawValue {
            expression.removeLast()
            if expression.isEmpty { // Prevent empty expression
                expression = ["0"]
                return
            }
            updateLastElement() // Update lastElement after removal
        }
        
        expression = expression.map { element in
            if Double(element) != nil || (element.starts(with: "-") && Double(element.dropFirst()) != nil) {
                return normalizeNumber(element)
            }
            return element
        }
        
        while openParenthesisCount > closeParenthesisCount {
            expression.append(Button.closeParenthesis.rawValue)
        }
        
        let operatorCount = expression.filter { Button(rawValue: $0)?.isOperator == true }.count
        let operandCount = expression.filter { Double($0) != nil }.count
        guard operandCount > operatorCount else { // Ensure enough operands
            expression = [Errors.undefined.rawValue]
            isRecalculation = true
            isNegativeNumber = false
            return
        }
        
        calculate()
        
        let calculationResult = calculator.result
        
        guard Button(rawValue: lastElement)?.isOperator != true else { return }
        print("Result: \(calculationResult)")
        print("Last element:", lastElement)
        
        expression = calculationResult.isNaN ? [Errors.undefined.rawValue] : checkResult(calculationResult: calculationResult)
        updateClearButton(isBackspace: false)
        isRecalculation = true
        isNegativeNumber = false
//        saveCalculation(model: Calculator(expression: expression, result: calculationResult))
    }
    
    func didTapBackspaceButton() {
        guard !expression.isEmpty, expression != ["0"] else { return }
        
        if firstElement == Errors.undefined.rawValue {
            expression = []
        }
        
        if lastElement.count > 1 {
            // Remove only the last character of the number
            lastElement.removeLast()
            expression[expression.count - 1] = lastElement
        } else {
            expression.removeLast()
        }
        
        // If expression becomes empty, reset to ["0"]
        if expression.isEmpty {
            expression = ["0"]
        }
    }
    
    func didTapClearButton() {
        expression = ["0"]
    }
    
    func didTapMicButton() {
        isRecording.toggle()
        if isRecording {
            startRecording()
        } else {
            stopRecording()
        }
        
        buttonsStackView.updateMicButton(isRecording: isRecording)
    }
}

// MARK: MainViewController Extension

extension MainViewController {
    private func calculate() {
        calculator.expression = expression
        calculator.result = updateResult(expression: expression)
        print("Model result", updateResult(expression: expression))
    }
    
    private func updateDisplay() {
        var formattedExpression = expression
        let missingCloseParentheses = openParenthesisCount - closeParenthesisCount
        if missingCloseParentheses > 0 {
            formattedExpression.append(contentsOf: Array(repeating: Button.closeParenthesis.rawValue, count: missingCloseParentheses))
        }
        
        let displayText = formattedExpression.joined()
        let attributedText = NSMutableAttributedString(string: displayText)
        
        // Make temporary ")" semi-transparent
        var addedCount = 0
        for (index, char) in displayText.enumerated().reversed() {
            if char == ")" && addedCount < missingCloseParentheses {
                let nsRange = NSRange(location: index, length: 1)
                attributedText.addAttribute(.foregroundColor, value: UIColor.label.withAlphaComponent(0.5), range: nsRange)
                addedCount += 1
            }
        }
        
        labelScrollView.updateText(attributedText: attributedText)
    }
    
    private func checkResult(calculationResult: Double) -> [String] {
        let absValue = abs(calculationResult)
        
        // Use scientific notation for very large/small numbers
        if absValue >= 1e10 || (absValue > 0 && absValue < 1e-3) {
            return [String(format: "%g", calculationResult)]
        }
        
        // Round to 8 decimal places
        let roundedValue = Double(String(format: "%.8f", calculationResult)) ?? calculationResult
        
        // Remove trailing zeros after decimal point
        return [String(format: "%g", roundedValue)]
    }
    
    private func updateClearButton(isBackspace: Bool) {
        buttonsStackView.updateClearButton(isBackspace: isBackspace)
    }
}

extension MainViewController {
    private func updateElementsCount() {
        numOfOperands = expression.filter { Double($0) != nil }.count
        numOfOperators = expression.filter { Button(rawValue: $0)?.isOperator == true }.count
        openParenthesisCount = expression.filter { $0 == Button.openParenthesis.rawValue }.count
        closeParenthesisCount = expression.filter { $0 == Button.closeParenthesis.rawValue }.count
    }
    
    private func updateFirstElement() {
        firstElement = expression.first ?? ""
    }
    
    private func updateLastElement() {
        lastElement = expression.last ?? ""
    }
    
    private func updateResult(expression: [String]) -> Double {
        var result: Double = 0.0
        rpnExpression = convertToRPN(expression)
        result = calculateRPN(rpnExpression)
        return result
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

extension MainViewController {
    private func startRecording() {
        do {
            try speechController.startRecording()
        } catch {
            print("Could not begin recording")
        }
    }
    
    private func stopRecording() {
        speechController.stopRecording()
    }
}

// MARK: SpeechController

extension MainViewController: SpeechControllerDelegate {
    func speechController(_ speechController: SpeechController, didRecogniseText text: String) {
        print("Text: \(text)")
        guard let lastWord = text.components(separatedBy: .whitespaces).last?.lowercased(), let character = textAndButton[lastWord], let button = Button(rawValue: character) else {
            return
        }
    
        if button.isOperator {
            didTapOperatorButton(button)
        } else if button.isNumber {
            didTapNumberButton(button)
        } else if button == .equals {
            didTapEqualsButton()
        }
    }
}
