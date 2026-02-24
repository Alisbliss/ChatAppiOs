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
    private var unReadCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.unreadMsgLabel.isHidden = self.unReadCount == 0
            }
        }
    }
    
    private let tableView = UITableView()
    
    private let unreadMsgLabel: UILabel = {
        let label = UILabel()
        label.text = "7"
        label.textColor = .white
        label.backgroundColor = .red
        label.setDimensions(height: 40, width: 40)
        label.layer.cornerRadius = 20
        label.textAlignment = .center
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    private var conversations: [Message] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var conversationDictionary = [String: Message]()
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
        fetchConversation()
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
        
        view.addSubview(unreadMsgLabel)
        unreadMsgLabel.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 20, paddingBottom: 10)
    }
    
    private func fetchConversation() {
        MessageService.fetchRecentMessages { [unowned self] conversations in
            conversations.forEach { conversation in
                self.conversationDictionary[conversation.chatPartnerID] = conversation
            }
            self.conversations = Array(self.conversationDictionary.values)
            unReadCount = 0
            self.conversations.forEach { msg in
                unReadCount += msg.new_msg
            }
            unreadMsgLabel.text = "\(unReadCount)"
            UIApplication.shared.applicationIconBadgeNumber = unReadCount
        }
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
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
        
    }
    
    private func openChat(currentUser: User, otherUser: User) {
        let controller = ChatViewController(currentUser: currentUser, otherUser: otherUser)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: = TableView
extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.description(), for: indexPath) as! ConversationCell
        let conversation = conversations[indexPath.row]
        cell.viewModel = MessageViewModel(message: conversation)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        
        showLoader(true)
        UserService.fetchUser(uid: conversation.chatPartnerID) { [unowned self] otherUser in
            showLoader(false)
            openChat(currentUser: user, otherUser: otherUser)
        }
    }
    
}

extension ConversationViewController: NewConversationControllerDelegate {
    func controller(_vc: NewConversationController, wantChatWithUser otherUser: User) {
        _vc.dismiss(animated: true, completion: nil)
        print(otherUser.fullname)
        openChat(currentUser: user, otherUser: otherUser)
    }
}
