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
    "ноль": "0",
    "один": "1",
    "два": "2",
    "три": "3",
    "четыре": "4",
    "пять": "5",
    "шесть": "6",
    "семь": "7",
    "восемь": "8",
    "девять": "9",
    "плюс": "+",
    "минус": "-",
    "умножь": "×",
    "раздели": "÷",
    "точка": ".",
    "равно": "=",
    "открой": "(",
    "закрой": ")",
    "очисти": "AC",
    "удали": "⌫",
    "стоп": "M"
    
]
