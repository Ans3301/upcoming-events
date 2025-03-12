//
//  ViewController.swift
//  upcoming-events
//
//  Created by Мария Анисович on 10.03.2025.
//

import SwifterSwift
import UIKit

final class ViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "My Events"
        label.font = UIFont(name: "Poppins-Medium", size: 34)
        label.textColor = .black
        return label
    }()
 
    private var weekButton = PeriodButton()
    private var monthButton = PeriodButton()
    private var yearButton = PeriodButton()
    private var customButton = PeriodButton()
    private lazy var buttons = [weekButton, monthButton, yearButton, customButton]
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 9
        stackView.distribution = .fillProportionally
        return stackView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTitleLabel()
        setupStackView()
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 52),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupStackView() {
        weekButton.setTitle("Week", for: .normal)
        monthButton.setTitle("Month", for: .normal)
        yearButton.setTitle("Year", for: .normal)
        customButton.setTitle("Custom", for: .normal)
        
        weekButton.isSelected = true

        for button in buttons {
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
                
        stackView.addArrangedSubviews(buttons)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 117),
            stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06)
        ])
    }
    
    @objc private func buttonTapped(_ button: UIButton) {
        for b in buttons {
            if b !== button {
                b.isSelected = false
            }
        }
    }
}
