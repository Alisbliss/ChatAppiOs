//
//  CustomImageView.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 17.02.2026.
//

import UIKit

class CustomImageView: UIImageView {
    
    init(image: UIImage? = nil, width: CGFloat? = nil, height: CGFloat? = nil, backgroundColor: UIColor? = nil, cornerRadius: CGFloat = 0) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFit
        if let image = image {
            self.image = image
        }
        if let width = width {
            setWidth(width)
        }
        if let height = height {
            setHeight(height)
        }
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        self.layer.cornerRadius = cornerRadius
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
