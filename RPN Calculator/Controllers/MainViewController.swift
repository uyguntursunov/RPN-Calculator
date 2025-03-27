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
    
    private var calculatorState: CalculatorState = .initial
    private var isRecording: Bool = false
    
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
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
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
            let attributedText = NSMutableAttributedString(string: expression.joined())
            print("Formatted expression", attributedText)
            self?.labelScrollView.updateText(attributedText: attributedText)
        }
        
        viewModel.clearButtonStateDidChange = { [weak self] isBackspace in
            self?.buttonsStackView.updateClearButton(isBackspace: isBackspace)
        }
        
        viewModel.calculatorStateDidChange = { [weak self] state in
            self?.calculatorState = state
        }
        
        viewModel.resultDidChange = { [weak self] result in
            guard let formatted = self?.formatExpression(calculationResult: result) else { return }
            let attributedText = NSMutableAttributedString(string: formatted.joined())
            print("Formatted expression", formatted)
            self?.labelScrollView.updateText(attributedText: attributedText)
        }
    }
    
    private func formatExpression(calculationResult: Double) -> [String] {
        let absValue = abs(calculationResult)
        if absValue >= 1e10 || (absValue > 0 && absValue < 1e-3) {
            return [String(format: "%g", calculationResult)]
        }
        let roundedValue = Double(String(format: "%.8f", calculationResult)) ?? calculationResult
        
        return [String(format: "%g", roundedValue)]
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

