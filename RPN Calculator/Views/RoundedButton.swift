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
        
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
    
    private func setupButton() {
        self.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func buttonTouchDown() {
        guard let title = titleLabel?.text, let button = Button(rawValue: title) else { return }
        animateButton(to: highlightColor(button.backgroundColor))
    }
    
    @objc private func buttonTouchUp() {
        guard let title = titleLabel?.text, let button = Button(rawValue: title) else { return }
        animateButton(to: button.backgroundColor)
    }
    
    private func animateButton(to color: UIColor) {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
            self.backgroundColor = color
        })
    }
    
    private func highlightColor(_ color: UIColor) -> UIColor {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            // If brightness is already high, reduce saturation instead
            if brightness > 0.9 {
                let newSaturation = max(saturation - 0.3, 0.0) // Desaturate by 30%
                return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
            } else {
                // For less bright colors, increase brightness
                let newBrightness = min(brightness + 0.2, 1.0)
                return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
            }
        }
}
