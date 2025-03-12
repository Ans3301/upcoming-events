//
//  PeriodButton.swift
//  upcoming-events
//
//  Created by Мария Анисович on 12.03.2025.
//

import SwifterSwift
import UIKit

final class PeriodButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.tintColor = .clear
        self.layer.cornerRadius = 13
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 15)

        self.setTitleColor(UIColor(hexString: "#2D2D2D"), for: .normal)
        self.setTitleColor(UIColor(hexString: "#2D2D2D"), for: .highlighted)
        self.setTitleColor(.white, for: .selected)

        self.configuration = .plain()
        self.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 16, bottom: 13, trailing: 16)

        self.configurationUpdateHandler = { button in
            button.backgroundColor = button.isSelected ? UIColor(hexString: "#5856D6") : UIColor(hexString: "#767680", transparency: 0.12)
        }

        self.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
    }

    @objc func buttonTapped(_ button: UIButton) {
        button.isSelected = true
    }
}
