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
