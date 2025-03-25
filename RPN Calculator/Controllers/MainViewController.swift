//
//  MainViewController.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 07/03/25.
//

import UIKit

protocol MainViewControllerDelegate: AnyObject {
    func didTapButton(_ button: Button)
    func didTapMicButton()
}

class MainViewController: UIViewController {
    
    lazy var speechController: SpeechController = {
        let speechController = SpeechController()
        speechController.delegate = self
        return speechController
    }()
    
    private let buttonsStackView = ButtonsStackView()
    private let labelScrollView = LabelScrollView()
    private let viewModel = CalculatorViewModel()
    private var isRecording: Bool = false
    private var isFinalResult: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        bindViewModel()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        buttonsStackView.configureLayout(shouldRemoveAllElements: true)
    }
    
    private func configureLayout() {
        let topPadding: CGFloat = 75.0
        let padding: CGFloat = 10.0
        let labelBottomSpacing: CGFloat = 20.0
        
        view.backgroundColor = .systemBackground
        buttonsStackView.delegate = self
        
        [buttonsStackView, labelScrollView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -topPadding),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            labelScrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -labelBottomSpacing),
            labelScrollView.leadingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor),
            labelScrollView.trailingAnchor.constraint(equalTo: buttonsStackView.trailingAnchor),
            labelScrollView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func bindViewModel() {
        viewModel.expressionDidChange = { [weak self] expression in
            guard let formatted = self?.formatExpression(expression: expression).joined() else { return }
            let attributedText = NSMutableAttributedString(string: formatted)
            print("Formatted expression", formatted)
            self?.labelScrollView.updateText(attributedText: attributedText)
        }
        
        viewModel.clearButtonStateDidChange = { [weak self] isBackspace in
            self?.buttonsStackView.updateClearButton(isBackspace: isBackspace)
        }
    }
    
    private func formatExpression(expression: [String]) -> [String] {
        expression.map { element in
            if Double(element) != nil && !element.hasSuffix(".") {
                return formatWithThousandsSeparator(element)
            }
            return element
        }
    }
    
    private func formatWithThousandsSeparator(_ number: String) -> String {
        guard let value = Double(number) else { return number }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 10
        
        let absValue = abs(value)
        if isFinalResult && (absValue >= 1e10 || (absValue > 0 && absValue < 1e-3)) {
            return String(format: "%g", value)
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? number
    }
}

// MARK: MainViewControllerDelegate Button Actions

extension MainViewController: MainViewControllerDelegate {
    func didTapButton(_ button: Button) {
        viewModel.handleButton(button)
    }
    
    func didTapMicButton() {
        toggleRecording()
    }
}

// MARK: Recording Speech 

extension MainViewController {
    func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            startRecording()
        } else {
            stopRecording()
        }
        
        buttonsStackView.updateMicButton(isRecording: isRecording)
    }
    
    private func startRecording() {
        do {
            try speechController.startRecording()
        } catch {
            print("Could not begin recording")
        }
    }
    
    private func stopRecording() {
        speechController.stopRecording()
    }
}

// MARK: Speech Controller Delegate

extension MainViewController: SpeechControllerDelegate {
    func speechController(_ speechController: SpeechController, didRecogniseText text: String) {
        print("Original Text: \(text)")
        
        let normalizedText = text
            .replacingOccurrences(of: "+", with: " + ")
            .replacingOccurrences(of: "-", with: " - ")
            .replacingOccurrences(of: "*", with: " * ")
            .replacingOccurrences(of: "/", with: " / ")
        
        let components = normalizedText.split(separator: " ").map { String($0) }
        var processedComponents: [String] = []
        
        for component in components {
            if let number = Int(component), number > 9 {
                let digits = String(number).map { String($0) }
                processedComponents.append(contentsOf: digits)
            } else {
                if let element = wordToElement[component.lowercased()] {
                    processedComponents.append(element)
                } else {
                    processedComponents.append(component)
                }
            }
        }
        
        if let lastWord = processedComponents.last?.lowercased(), let button = Button(rawValue: lastWord) {
            didTapButton(button)
        }
    }
}

