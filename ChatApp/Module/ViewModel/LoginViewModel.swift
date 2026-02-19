//
//  Untitled.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 16.02.2026.
//

import UIKit

protocol AuthLogimModel {
    var formValid: Bool { get }
    
    var backbroundColor: UIColor { get }
    
    var buttonTintColor: UIColor { get }
}

struct LoginViewModel: AuthLogimModel {
    var email: String?
    var password: String?
    
    var formValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var backbroundColor: UIColor {
        return formValid ? (UIColor.black) : (UIColor.black.withAlphaComponent(0.5))
    }
    
    var buttonTintColor: UIColor {
        return formValid ? (UIColor.white) : UIColor(white: 1, alpha: 0.7)
    }
}
