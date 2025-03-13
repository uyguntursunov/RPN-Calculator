//
//  RoundedButton.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 08/03/25.
//

import UIKit

class RoundedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
    
//    private func setupButton() {
//        self.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
//        self.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
//    }
//    
//    @objc private func buttonTouchDown() {
//        guard let backgroundColor = backgroundColor else { return }
//        animateButton(to: backgroundColor.withAlphaComponent(0.5)) // Pressed color
//    }
//    
//    @objc private func buttonTouchUp() {
//        guard let backgroundColor = backgroundColor else { return }
//        animateButton(to: backgroundColor) // Normal color
//    }
//    
//    private func animateButton(to color: UIColor) {
//        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
//            self.backgroundColor = color
//        })
//    }
}
