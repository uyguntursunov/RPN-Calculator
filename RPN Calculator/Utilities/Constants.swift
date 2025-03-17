//
//  Constants.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 07/03/25.
//

import UIKit

let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .default)

enum Errors: String {
    case undefined = "Undefined"
}

enum SFSymbols {
    static let microphone = UIImage(systemName: "microphone", withConfiguration: largeConfig)
}

let wordToElement: [String: String] = [
    "zero": "0",
    "one": "1",
    "two": "2",
    "three": "3",
    "four": "4",
    "five": "5",
    "six": "6",
    "seven": "7",
    "eight": "8",
    "nine": "9",
    "plus": "+",
    "minus": "-",
    "multiply": "×",
    "divide": "÷",
    "dot": ".",
    "equals": "=",
    "open": "(",
    "close": ")",
    "clear": "AC",
    "delete": "⌫",
    "stop": "M"
]
