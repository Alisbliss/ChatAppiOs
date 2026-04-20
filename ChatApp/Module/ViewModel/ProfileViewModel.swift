//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 24.03.2026.
//

import Foundation

enum ProfileField: Int, CaseIterable {
    case fullname
    case username
    case email
    
    var description: String {
        switch self {
            
        case .fullname:
            return "Fullname"
        case .username:
            return "Username"
        case .email:
            return "Email Adress"
        }
    }
}
struct ProfileViewModel {
    let user: User
    
    let field: ProfileField
    
    var fieldTitle: String {
        return field.description
    }
    var optionType: String?{
        switch field {
        case .fullname:
            return user.fullname
        case .username:
            return user.username
        case .email:
            return user.email
        }
    }
    init(user: User, field: ProfileField) {
        self.user = user
        self.field = field
    }
}
