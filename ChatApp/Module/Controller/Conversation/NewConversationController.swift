//
//  NewConversationController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit
import FirebaseAuth

protocol NewConversationControllerDelegate: AnyObject {
    func controller(_vc: NewConversationController, wantChatWithUser otherUser: User)
}

class NewConversationController: UIViewController {
    
    //MARK: Properties
    weak var delegate: NewConversationControllerDelegate?
    private let tableView = UITableView()
    
    private var users: [User] = []{
        didSet {
            self.tableView.reloadData()
        }
    }
    
    //MARK: LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureTableView()
        fetchUsers()
    }
    
    //MARK: Helpers
    private func configure() {
        view.backgroundColor = .white
        title = "Search"
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingRight: 15)
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 64
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.description())
        tableView.tableFooterView = UIView() //empty space and noting
    }
    
    private func fetchUsers() {
        showLoader(true)
        UserService.fetchUsers() { users in
            self.showLoader(false)
            self.users = users
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let index = self.users.firstIndex(where: { user in
                user.uid == uid
            }) else { return }
            self.users.remove(at: index)
            print("\(users)")
        }
    }
}

extension NewConversationController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.description(), for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.viewModel = UserViewModel(user: user)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        delegate?.controller(_vc: self, wantChatWithUser: user)
    }
}
