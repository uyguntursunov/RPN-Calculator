//
//  RoundedButton.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 08/03/25.
//

import UIKit

final class RoundedButton: UIButton {
    
    init(button: Button) {
        super.init(frame: .zero)
        setupButton()
        configure(button: button)
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
            
            if brightness > 0.9 {
                let newSaturation = max(saturation - 0.3, 0.0)
                return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
            } else {
                let newBrightness = min(brightness + 0.2, 1.0)
                return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
            }
        }
}

extension UIButton {
    func configure(button: Button) {
        self.setTitle(button.rawValue, for: .normal)
        self.backgroundColor = button.backgroundColor
        self.titleLabel?.font = .systemFont(ofSize: button.fontSize, weight: button.fontWeight)
        self.setTitleColor(.label, for: .normal)
    }
    
    func startAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.duration = 0.6
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        self.layer.add(pulseAnimation, forKey: "pulsing")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.7
        opacityAnimation.duration = 0.6
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        self.layer.add(opacityAnimation, forKey: "opacity")
    }
    
    func stopAnimation() {
        self.layer.removeAnimation(forKey: "pulsing")
        self.layer.removeAnimation(forKey: "opacity")
    }
}
