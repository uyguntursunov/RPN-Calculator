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
        case .allClear: return .clear
        case .backspace: return .backspace
        }
    }
}

class ButtonsStackView: UIStackView {
    
    private var clearButton: UIButton?
    private var micButton: UIButton?
    private var currentAllClearState: ClearButtonState = .allClear
    private let mySpacing: CGFloat = 10.0
    private let animationLayer = CALayer()
    
    weak var delegate: MainViewControllerDelegate?
    
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
                let calcButton = buttons[index]
                let button = RoundedButton()
                
                button.configure(title: calcButton.rawValue, backgroundColor: calcButton.backgroundColor, fontSize: calcButton.fontSize, fontWeight: calcButton.fontWeight)
                button.setTitleColor(.label, for: .normal)
                
                clearButton = calcButton == .clear ? button : clearButton
                micButton = calcButton == .mic ? button : micButton
                
                if calcButton == .mic {
                    configureMicButton()
                }
                
                let buttonAction = setButtonAction(calcButton)
                if let buttonAction = buttonAction { button.addTarget(self, action: buttonAction, for: .touchUpInside) }
                horizontalSv.addArrangedSubview(button)
            }
            
            addArrangedSubview(horizontalSv)
        }
    }
}

// MARK: ButtonsStackView Extension

extension ButtonsStackView {
    func updateClearButton(isBackspace: Bool) {
        currentAllClearState = isBackspace ? .backspace : .allClear
        let buttonConfig = currentAllClearState.button
        
        clearButton?.configure(title: buttonConfig.rawValue, backgroundColor: buttonConfig.backgroundColor, fontSize: buttonConfig.fontSize, fontWeight: buttonConfig.fontWeight)
        
        clearButton?.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = setButtonAction(buttonConfig) {
            clearButton?.addTarget(self, action: action, for: .touchUpInside)
        }
    }
    
    func configureMicButton() {
        micButton?.setTitle("", for: .normal)
        micButton?.setImage(SFSymbols.microphone, for: .normal)
        micButton?.tintColor = .label
    }
    
    func updateMicButton(isRecording: Bool) {
        micButton?.backgroundColor = isRecording ? .operationButton : .numButton
        if isRecording {
            micButton?.startAnimation()
        } else {
            micButton?.stopAnimation()
        }
    }
}


// MARK: Calculator Buttons' Actions

extension ButtonsStackView {
    private func setButtonAction(_ button: Button) -> Selector? {
        var buttonAction: Selector?
        switch button {
        case .clear:
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
        case .mic:
            buttonAction = #selector(didTapCButton)
        default:
            buttonAction = #selector(didTapNumberButton(_:))
        }
        
        return buttonAction
    }
    
    @objc func didTapNumberButton(_ sender: UIButton) {
        guard let element = sender.currentTitle, let num = Button(rawValue: element) else { return }
        delegate?.didTapNumberButton(num)
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
    
    @objc func didTapCButton() {
        delegate?.didTapMicButton()
    }
}
