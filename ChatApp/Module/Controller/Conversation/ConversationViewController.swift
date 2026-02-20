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
    
    private let tableView = UITableView()
    
    //MARK: LifeCircle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configure()
    }
    
    //MARK: Helpers
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.description())
        tableView.tableFooterView = UIView() //empty space and noting
    }
    
    private func configure() {
        view.backgroundColor = .white
    
        let logoutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLogout))
        
        let newConversation = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewChat))
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem = newConversation
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingRight: 15)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            
            dismiss(animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func handleNewChat() {
        let controller = NewConversationController()
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
        
    }
}

//MARK: = TableView
extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.description(), for: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ChatViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
