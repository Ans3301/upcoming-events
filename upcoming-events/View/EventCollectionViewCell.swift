//
//  EventTableViewCell.swift
//  upcoming-events
//
//  Created by Мария Анисович on 12.03.2025.
//

import SwifterSwift
import UIKit

final class EventCollectionViewCell: UICollectionViewCell {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont(name: "Poppins-Regular", size: 17)
        label.textColor = .black
        return label
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont(name: "Poppins-Regular", size: 17)
        label.textColor = UIColor(hexString: "#5856D6")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 3
        backgroundColor = UIColor(hexString: "F2F2F2", transparency: 0.8)
        
        setupNameLabel()
        setupTimerLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNameLabel() {
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.63)
        ])
    }
    
    private func setupTimerLabel() {
        contentView.addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            timerLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            timerLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.37)
        ])
    }
    
    func configure(text: String, remainingTime: String) {
        nameLabel.text = text
        timerLabel.text = remainingTime
    }
}
