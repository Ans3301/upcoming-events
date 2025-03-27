//
//  InputView.swift
//  upcoming-events
//
//  Created by Мария Анисович on 25.03.2025.
//

import SwifterSwift
import UIKit

final class InputView: UIView {
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.placeholder = "Title"
        textField.font = UIFont(name: "Poppins-Regular", size: 17)
        return textField
    }()

    private lazy var separator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor(hexString: "#3C3C435C", transparency: 0.36)
        return separator
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Start"
        label.textAlignment = .left
        label.font = UIFont(name: "Poppins-Regular", size: 17)
        label.textColor = .black
        return label
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = Date()
        return picker
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        setupTextField()
        setupSeparator()
        setupLabel()
        setupDatePicker()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        addShadow()
    }

    private func addShadow() {
        layer.masksToBounds = false
        layer.cornerRadius = 13
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 13).cgPath
        layer.shadowColor = UIColor(hexString: "#000000")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 20
    }

    private func setupTextField() {
        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            textField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95)
        ])
    }

    private func setupSeparator() {
        addSubview(separator)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            separator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupLabel() {
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 70),
            label.leadingAnchor.constraint(equalTo: textField.leadingAnchor)
        ])
    }

    private func setupDatePicker() {
        addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            datePicker.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 15)
        ])
    }

    func addTextFieldTarget(_ target: Any?, action: Selector) {
        textField.addTarget(target, action: action, for: .editingChanged)
    }

    func getTitle() -> String? {
        return textField.text
    }

    func getDate() -> Date {
        return datePicker.date
    }
}
