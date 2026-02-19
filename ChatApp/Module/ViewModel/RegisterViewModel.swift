//
//  RegisterViewModel.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 16.02.2026.
//

import UIKit

struct RegisterViewModel: AuthLogimModel {
    var email: String?
    var password: String?
    var fullName: String?
    var userName: String?
    
    var formValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false && fullName?.isEmpty == false && userName?.isEmpty == false
    }
    
    var backbroundColor: UIColor {
        return formValid ? (UIColor.black) : (UIColor.black.withAlphaComponent(0.5))
    }
    
    var buttonTintColor: UIColor {
        return formValid ? (UIColor.white) : UIColor(white: 1, alpha: 0.7)
    }
}
