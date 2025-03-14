//
//  UIButton + Extension.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 14/03/25.
//

import UIKit

extension UIButton {
    func configure(title: String, backgroundColor: UIColor, fontSize: CGFloat, fontWeight: UIFont.Weight) {
        self.setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        self.titleLabel?.font = .systemFont(ofSize: fontSize, weight: fontWeight)
    }
    
    func startAnimation() {
        // Create pulsating effect
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.duration = 0.6
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        self.layer.add(pulseAnimation, forKey: "pulsing")
        
        // Optional: Add a subtle opacity animation
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
