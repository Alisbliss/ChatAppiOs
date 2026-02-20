//
//  NewConversationController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit

class NewConversationController: UIViewController {
    
    //MARK: Properties
    private let tableView = UITableView()
    
    //MARK: LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureTableView()
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
}

extension NewConversationController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.description(), for: indexPath)
        return cell
    }
}
