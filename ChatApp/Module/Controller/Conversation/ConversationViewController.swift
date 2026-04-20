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
    private var conversations: [Message] = [] {
        didSet {
            emptyView.isHidden = !conversations.isEmpty
            tableView.reloadData()
        }
    }
    
    private var filteredConversation: [Message] = []
    
    private var searchController = UISearchController(searchResultsController: nil)
    private var conversationDictionary = [String: Message]()
    
    var isSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
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
    
    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .red
        button.setDimensions(height: 40, width: 40)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleFrofileButton), for: .touchUpInside)
        return button
    }()
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let emptyLabel = CustomLabel(text: "There is no conversation. Click add to start chating now", labelColor: .yellow)
    
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
        configureSearchController()
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
        title = user.fullname
        let logoutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLogout))
        
        let newConversation = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewChat))
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem = newConversation
     
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingRight: 15)
        
        view.addSubview(unreadMsgLabel)
        unreadMsgLabel.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 20, paddingBottom: 10)
        
        view.addSubview(profileButton)
        profileButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 10, paddingRight: 20)
        
        view.addSubview(emptyView)
        emptyView.anchor(left: view.leftAnchor, bottom: profileButton.bottomAnchor, right: view.rightAnchor, paddingLeft: 25, paddingBottom: 50, paddingRight: 25, height: 50)
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.anchor(top: emptyView.topAnchor, left: emptyView.leftAnchor, bottom: emptyView.bottomAnchor, right: emptyView.rightAnchor, paddingTop: 7, paddingLeft: 7, paddingBottom: 7, paddingRight: 7)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateprofile), name: .userProfile, object: nil)
    }
    
    private func configureSearchController() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "search"
        navigationItem.searchController = searchController
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
    
    @objc func handleFrofileButton() {
        let controller = ProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleUpdateprofile() {
        UserService.fetchUser(uid: user.uid) {[weak self] user in
            guard let self else { return }
            self.user = user
            self.title = user.fullname
            
        }
    }
    
    private func openChat(currentUser: User, otherUser: User) {
        let controller = ChatViewController(currentUser: currentUser, otherUser: otherUser)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: = TableView
extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? filteredConversation.count : conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.description(), for: indexPath) as! ConversationCell
        let conversation = isSearchMode ? filteredConversation[indexPath.row] : conversations[indexPath.row]
        cell.viewModel = MessageViewModel(message: conversation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = isSearchMode ? filteredConversation[indexPath.row] : conversations[indexPath.row]
        
        showLoader(true)
        UserService.fetchUser(uid: conversation.chatPartnerID) { [unowned self] otherUser in
            showLoader(false)
            openChat(currentUser: user, otherUser: otherUser)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        showLoader(true)
        let conversation = isSearchMode ? filteredConversation[indexPath.row] : conversations[indexPath.row]
        MessageService.deleteMessage(otherUser: conversation.toID) { [weak self] error in
            guard let self else { return }
            showLoader(false)
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if editingStyle == .delete {
                if self.isSearchMode {
                    filteredConversation.remove(at: indexPath.row)
                } else {
                    conversations.remove(at: indexPath.row)
                }
            }
        }
    }
}
//MARK: NewConversationControllerDelegate
extension ConversationViewController: NewConversationControllerDelegate {
    func controller(_vc: NewConversationController, wantChatWithUser otherUser: User) {
        _vc.dismiss(animated: true, completion: nil)
        print(otherUser.fullname)
        openChat(currentUser: user, otherUser: otherUser)
    }
}

//MARK: UISearchResultsUpdating
extension ConversationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredConversation = conversations.filter({$0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)})
        tableView.reloadData()
    }
}

//MARK: UISearchBarDelegate
extension ConversationViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.showsCancelButton = false
    }
}
