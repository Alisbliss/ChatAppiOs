//
//  CustomLabel.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 16.02.2026.
//

import UIKit

class CustomLabel: UILabel {
    init(text: String, labelFont: UIFont = .systemFont(ofSize: 14, weight: .regular), labelColor: UIColor = .black) {
        super.init(frame: .zero)
        self.text = text
        font = labelFont
        textColor = labelColor
        textAlignment = .center
        numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
