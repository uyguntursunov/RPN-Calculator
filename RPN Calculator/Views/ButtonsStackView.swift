//
//  ButtonsStackView.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 07/03/25.
//

import UIKit

private enum ClearButtonState {
    case allClear
    case backspace
    
    var button: Button {
        switch self {
        case .allClear: return .allClear
        case .backspace: return .backspace
        }
    }
}

class ButtonsStackView: UIStackView {
    
    private var allClearButton: UIButton?
    private var currentAllClearState: ClearButtonState = .allClear
    weak var delegate: MainViewControllerDelegate?
    let mySpacing: CGFloat = 10.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        spacing = mySpacing
        
        let numOfRows: Int = 5
        let numOfColumns: Int = 4
        let buttons = Button.allCases
        
        for row in 0 ..< numOfRows {
            let horizontalSv = UIStackView()
            horizontalSv.axis = .horizontal
            horizontalSv.alignment = .fill
            horizontalSv.distribution = .fillEqually
            horizontalSv.spacing = mySpacing
            
            for col in 0 ..< numOfColumns {
                let index = row * numOfColumns + col
                guard index < buttons.count else { continue }
                let calculatorButton = buttons[index]
                let button = RoundedButton()
                
                button.setTitle(calculatorButton.rawValue, for: .normal)
                button.setTitleColor(.label, for: .normal)
                button.backgroundColor = calculatorButton.backgroundColor
                button.titleLabel?.font = UIFont.systemFont(ofSize: calculatorButton.fontSize, weight: calculatorButton.fontWeight)
                
                if calculatorButton == .allClear {
                    allClearButton = button
                }
                
                let buttonAction = setButtonAction(calculatorButton)
                if let buttonAction = buttonAction { button.addTarget(self, action: buttonAction, for: .touchUpInside) }
                horizontalSv.addArrangedSubview(button)
            }
            
            addArrangedSubview(horizontalSv)
        }
    }
}

// MARK: ButtonsStackView Extension

extension ButtonsStackView {
    private func setButtonAction(_ button: Button) -> Selector? {
        var buttonAction: Selector?
        switch button {
        case .allClear:
            buttonAction = #selector(didTapClearButton)
        case .equals:
            buttonAction = #selector(didTapEqualsButton)
        case .divide, .multiply, .add, .subtract:
            return #selector(didTapOperatorButton(_:))
        case .decimalSeparator:
            buttonAction = #selector(didTapDecimalButton)
        case .openParenthesis:
            buttonAction = #selector(didTapOpenParenthesisButton)
        case .closeParenthesis:
            buttonAction = #selector(didTapCloseParenthesisButton)
        case .backspace:
            buttonAction = #selector(didTapBackspaceButton)
        case .clear:
            break
        default:
            buttonAction = #selector(didTapNumberButton(_:))
        }
        
        return buttonAction
    }
    
    func updateAllClearButton(isBackspace: Bool) {
        guard let button = allClearButton else { return }
        currentAllClearState = isBackspace ? .backspace : .allClear
        let buttonConfig = currentAllClearState.button
        
        button.setTitle(buttonConfig.rawValue, for: .normal)
        button.backgroundColor = buttonConfig.backgroundColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: buttonConfig.fontSize,
                                                    weight: buttonConfig.fontWeight)
        
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = setButtonAction(buttonConfig) {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
    }
}

// MARK: Calculator Buttons' Actions

extension ButtonsStackView {
    @objc func didTapNumberButton(_ sender: UIButton) {
        guard let element = sender.currentTitle else { return }
        delegate?.didTapNumberButton(element)
    }
    
    @objc func didTapOperatorButton(_ sender: UIButton) {
        guard let element = sender.currentTitle, let op = Button(rawValue: element) else { return }
        delegate?.didTapOperatorButton(op)
    }
    
    @objc func didTapBackspaceButton() {
        delegate?.didTapBackspaceButton()
    }
    
    @objc func didTapDecimalButton() {
        delegate?.didTapDecimalButton()
    }
    
    @objc func didTapOpenParenthesisButton() {
        delegate?.didTapOpenParenthesisButton()
    }
    
    @objc func didTapCloseParenthesisButton() {
        delegate?.didTapCloseParenthesisButton()
    }
    
    @objc func didTapEqualsButton() {
        delegate?.didTapEqualsButton()
    }
    
    @objc func didTapClearButton() {
        delegate?.didTapClearButton()
    }
}
