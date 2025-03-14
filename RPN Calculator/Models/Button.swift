//
//  Button.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 13/03/25.
//

import UIKit

enum Button: String, CaseIterable {
    case clear = "AC"
    case backspace = "⌫"
    case openParenthesis = "("
    case closeParenthesis = ")"
    case divide = "÷"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case multiply = "×"
    case four = "4"
    case five = "5"
    case six = "6"
    case subtract = "-"
    case one = "1"
    case two = "2"
    case three = "3"
    case add = "+"
    case mic = "M"
    case zero = "0"
    case decimalSeparator = "."
    case equals = "="
    
    var isNumber: Bool {
        Double(rawValue) != nil
    }
    
    var isOperator: Bool {
        switch self {
        case .add, .subtract, .multiply, .divide:
            return true
        default:
            return false
        }
    }
    
    static let allCases: [Button] = [
        .clear, .openParenthesis, .closeParenthesis, .divide,
        .seven, .eight, .nine, .multiply,
        .four, .five, .six, .subtract,
        .one, .two, .three, .add,
        .mic, .zero, .decimalSeparator, .equals
    ]
    
    var backgroundColor: UIColor {
        switch self {
        case .divide, .multiply, .add, .subtract, .equals:
            return .operationButton
        case .clear, .openParenthesis, .closeParenthesis, .backspace:
            return .funcButton
        default:
            return .numButton
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .divide, .multiply, .add, .subtract, .equals, .backspace:
            return 50
        default:
            return 32
        }
    }
    
    var fontWeight: UIFont.Weight {
        switch self {
        case .divide, .multiply, .add, .subtract, .equals, .backspace:
            return .light
        default:
            return .medium
        }
    }
}
