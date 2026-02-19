//
//  LoginGoogle.swift
//  ChatTheComplete
//
//  Created by Ahmad Mustafa on 02/02/2022.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseStorage

extension LoginViewController {

    func showTextInputPrompt(withMessage message: String,
                             completionBlock: @escaping ((Bool, String?) -> Void)) {
        let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        prompt.addTextField(configurationHandler: nil)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionBlock(false, nil)
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak prompt] _ in
            guard let text = prompt?.textFields?.first?.text else { return }
            completionBlock(true, text)
        }
        
        prompt.addAction(cancelAction)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    @objc func setupGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        showLoader(true)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showLoader(false)
          
                if (error as NSError).code != GIDSignInError.canceled.rawValue {
                    self.showMessage(title: "Error", message: error.localizedDescription)
                }
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.showLoader(false)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                self.showLoader(false)
                
                if let error = error {
                    let authError = error as NSError
                    
                    // Проверка на многофакторную аутентификацию (MFA)
                    if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                        self.handleMultiFactor(error: authError)
                    } else {
                        self.showMessage(title: "Error", message: error.localizedDescription)
                    }
                    return
                }
                
                self.updateUserInfo()
            }
        }
    }
    
    private func handleMultiFactor(error: NSError) {
        let resolver = error.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
        var displayNameString = ""
        for tmpFactorInfo in resolver.hints {
            displayNameString += (tmpFactorInfo.displayName ?? "") + " "
        }
        
        self.showTextInputPrompt(withMessage: "Select factor to sign in\n\(displayNameString)") { [weak self] ok, displayName in
            guard let self = self, ok, let displayName = displayName else { return }
            
            let selectedHint = resolver.hints.first { $0.displayName == displayName } as? PhoneMultiFactorInfo
            guard let hint = selectedHint else { return }
            
            self.showLoader(true)
            PhoneAuthProvider.provider().verifyPhoneNumber(with: hint, uiDelegate: nil, multiFactorSession: resolver.session) { [weak self] verificationID, error in
                guard let self = self else { return }
                self.showLoader(false)
                
                if let error = error {
                    self.showMessage(title: "Error", message: error.localizedDescription)
                    return
                }
                
                self.showTextInputPrompt(withMessage: "Verification code for \(hint.displayName ?? "")") { ok, code in
                    guard ok, let code = code, let vID = verificationID else { return }
                    
                    let credential = PhoneAuthProvider.provider().credential(withVerificationID: vID, verificationCode: code)
                    let assertion = PhoneMultiFactorGenerator.assertion(with: credential)
                    
                    self.showLoader(true)
                    resolver.resolveSignIn(with: assertion) { [weak self] result, error in
                        self?.showLoader(false)
                        if let error = error {
                            self?.showMessage(title: "Error", message: error.localizedDescription)
                        } else {
                            self?.updateUserInfo()
                        }
                    }
                }
            }
        }
    }
}

extension LoginViewController {
    func updateUserInfo() {
        

        guard let user = Auth.auth().currentUser else { return }
        
        guard let email = user.email,
              let fullname = user.displayName,
              let photoURL = user.photoURL else { return }
        
        let uid = user.uid
        let username = fullname.replacingOccurrences(of: " ", with: "").lowercased()
        getImage(withImageURL: photoURL) { [weak self] image in
            let credential = AuthCredentialEmail(email: email, uid: uid, username: username, fullname: fullname, profileImage: image)
            AuthServices.registerWithGoogle(credential: credential) { error in
                self?.showLoader(false)
                if let error = error {
                    self?.showMessage(title: "Error", message: error.localizedDescription)
                    return
                }
            }
        }
        
        print("Success create to firestore")
        self.navToConversationVC()
    }
}
