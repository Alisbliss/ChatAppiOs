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
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    private var users: [User] = []{
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var filtereUsers: [User] = []
    
    var isSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    //MARK: LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureTableView()
        fetchUsers()
        configureSearchController()
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
    
    private func configureSearchController() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "search"
        navigationItem.searchController = searchController
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
        return isSearchMode ? filtereUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.description(), for: indexPath) as! UserCell
        let user = isSearchMode ? filtereUsers[indexPath.row] : users[indexPath.row]
        cell.viewModel = UserViewModel(user: user)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = isSearchMode ? filtereUsers[indexPath.row] : users[indexPath.row]
        delegate?.controller(_vc: self, wantChatWithUser: user)
    }
}

//MARK: UISearchResultsUpdating
extension NewConversationController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filtereUsers = users.filter({$0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)})
        tableView.reloadData()
    }
}

//MARK: UISearchBarDelegate
extension NewConversationController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.showsCancelButton = false
    }
}
