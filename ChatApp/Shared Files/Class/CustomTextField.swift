//
//  CustomTextField.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 16.02.2026.
//

import UIKit

class CustomTextField: UITextField {
    
    init(placeHolder: String, keyBoardType: UIKeyboardType = .default, issecureText: Bool = false) {
        super.init(frame: .zero)
        
        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 12)
        leftView = spacer
        leftViewMode = .always
        
        borderStyle = .none
        textColor = .black
        keyboardAppearance = .light
        clearButtonMode = .whileEditing
        backgroundColor = #colorLiteral(red: 0.9656803012, green: 0.965680182, blue: 0.965680182, alpha: 1)
        setHeight(50)
        
        self.keyboardType = keyBoardType
        isSecureTextEntry = issecureText
        attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [.foregroundColor : UIColor.black.withAlphaComponent(0.7)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
