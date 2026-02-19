//
//  SplashVC.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 19.02.2026.
//

import UIKit
import FirebaseAuth

class SplashVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser?.uid == nil {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            showLoader(true)
            UserService.fetchUser(uid: uid) { [weak self] user in
                self?.showLoader(false)
                let controller = ConversationViewController(user: user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self?.present(nav, animated: true, completion: nil)
            }
        }
    }
}
