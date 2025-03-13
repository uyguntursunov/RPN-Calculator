//
//  ScrollableLabel.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 07/03/25.
//

import UIKit

class LabelScrollView: UIScrollView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .right
        label.text = "0"
        label.numberOfLines = 1
        return label
    }()
    
    private var isInitialLoad: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: self.bounds.height)
        
        if isInitialLoad {
            scrollToEnd()
            isInitialLoad = false
        }
        
        if self.panGestureRecognizer.translation(in: self.superview).x > 0 {
           print("left")
        } else {
           print("right")
        }
    }
    
    private func setupScrollView() {
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        self.backgroundColor = .clear
        self.addSubview(label)
        self.delegate = self
        
        let initialText = NSMutableAttributedString(string: "0")
        updateText(attributedText: initialText)

    }
    
    func updateText(attributedText: NSMutableAttributedString) {
        label.attributedText = attributedText
        updateLabelFontSize()
        label.sizeToFit()
        contentSize = CGSize(width: label.frame.width, height: frame.height)
        scrollToEnd()
    }
    
    private func scrollToEnd() {
        let rightOffset = CGPoint(x: contentSize.width - bounds.width, y: 0)
        setContentOffset(rightOffset, animated: false)
    }
    
    private func updateLabelFontSize() {
        var fontSize: CGFloat = 65.0
        if let count = label.text?.count {
            switch count {
            case 9:
                fontSize = 65.0 * 0.95
            case 10...:
                fontSize = 65.0 * 0.85
            default:
                fontSize = 65.0
            }
        }
        
        label.font = .systemFont(ofSize: fontSize, weight: .medium)
    }
}

extension LabelScrollView: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("Dragging ended")
    }
}
