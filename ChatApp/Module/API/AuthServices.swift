//
//  AuthServices.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 18.02.2026.
//

import UIKit
import Firebase
import FirebaseAuth

struct AuthCredential {
    let email: String
    let passward: String
    let username: String
    let fullname: String
    let profileImage: UIImage
}
   
struct AuthCredentialEmail {
    let email: String
    let uid: String
    let username: String
    let fullname: String
    let profileImage: UIImage
}
import FirebaseAuth

struct AuthServices {
    
    static func loginUser(withEmail email: String, withPassword password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(credential: AuthCredential, completion: @escaping (Error?) -> Void) {
        FileUploader.uploadImage(image: credential.profileImage) { imageUrl in
            print("imageURL: \(imageUrl)")
            Auth.auth().createUser(withEmail: credential.email, password: credential.passward) { result, error in
                if let error = error {
                    print("Error create account \(error.localizedDescription)")
                    return
                }
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = [
                    "email": credential.email,
                    "username": credential.username,
                    "fullname": credential.fullname,
                    "uid": uid,
                    "profileImageURL": imageUrl
                ]
                Collection_User.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    static func registerWithGoogle(credential: AuthCredentialEmail, completion: @escaping (Error?) -> Void) {
        FileUploader.uploadImage(image: credential.profileImage) { imageUrl in
            let data: [String: Any] = [
                "email": credential.email,
                "username": credential.username,
                "fullname": credential.fullname,
                "uid": credential.uid,
                "profileImageURL": imageUrl
            ]
            Collection_User.document(credential.uid).setData(data, completion: completion)
        }
    }
}
