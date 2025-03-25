//
//  ButtonsStackView.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 07/03/25.
//

import UIKit

private enum ClearButtonState {
    case clear
    case backspace
    
    var button: Button {
        switch self {
        case .clear: return .clear
        case .backspace: return .backspace
        }
    }
}

class ButtonsStackView: UIStackView {
    
    private var clearButton: UIButton?
    private var micButton: UIButton?
    private var currentClearButtonState: ClearButtonState = .clear
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
    
    func configureLayout(shouldRemoveAllElements: Bool = false) {
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        spacing = mySpacing
        
        if shouldRemoveAllElements {
            arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
        
        let buttons = UIDevice.current.orientation.isLandscape ? Button.allCasesLandscape : Button.allCases
        
        for row in 0 ..< buttons.count {
            let horizontalSv = UIStackView()
            horizontalSv.axis = .horizontal
            horizontalSv.alignment = .fill
            horizontalSv.distribution = .fillEqually
            horizontalSv.spacing = mySpacing
            
            for col in 0 ..< buttons[row].count {
                let calcButton = buttons[row][col]
                let button = RoundedButton(button: calcButton)
                                
                clearButton = calcButton == .clear ? button : clearButton
                micButton = calcButton == .mic ? button : micButton
                
                if calcButton == .mic {
                    configureMicButton()
                }
                
                button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
                horizontalSv.addArrangedSubview(button)
            }
            
            addArrangedSubview(horizontalSv)
        }
    }
    
    @objc func didTapButton(_ sender: UIButton) {
        guard let element = sender.currentTitle, let button = Button(rawValue: element) else { return }
        delegate?.didTapButton(button)
    }
    
    @objc func didTapMicButton(_ sender: UIButton) {
        delegate?.didTapMicButton()
    }
    
    @objc func didLongPressBackspaceButton(_ sender: UIButton) {
        delegate?.didTapButton(.clear)
    }
}

// MARK: ButtonsStackView Extension

extension ButtonsStackView {
    func updateClearButton(isBackspace: Bool) {
        currentClearButtonState = isBackspace ? .backspace : .clear
        let buttonConfig = currentClearButtonState.button
        clearButton?.configure(button: buttonConfig)
        if currentClearButtonState == .backspace {
            let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBackspaceButton))
            clearButton?.addGestureRecognizer(longGestureRecognizer)
        }
    }
    
    func configureMicButton() {
        micButton?.setTitle("", for: .normal)
        micButton?.setImage(SFSymbols.microphone, for: .normal)
        micButton?.tintColor = .label
        micButton?.addTarget(self, action: #selector(didTapMicButton), for: .touchUpInside)
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
