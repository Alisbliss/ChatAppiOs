//
//  ConversationViewController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 19.02.2026.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {
    
    //MARK: Properties
    private var user: User
    //MARK: LifeCircle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: Helpers
    func configure() {
        view.backgroundColor = .white
        title = user.fullname
        print(user.fullname)
        let logoutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            
            dismiss(animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}
