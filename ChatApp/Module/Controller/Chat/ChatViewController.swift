//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit

class ChatViewController: UICollectionViewController {
    //MARK: Properties
    private var messages: [Message] = []
    
    private lazy var customeInputView: CustomeInputView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let view = CustomeInputView(frame: frame)
        view.delegate = self
        return view
    }()
    
    private var currentUser: User
    private var otherUser: User
    //MARK: LifeCircle
    init(currentUser: User,otherUser: User) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        fetchMessages()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.markReadAllMsg()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        markReadAllMsg()
    }
    
    override var inputAccessoryView: UIView?{
        get {return customeInputView}
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: Helpers
    private func configure() {
        title = otherUser.fullname
        collectionView.backgroundColor = .white
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.description())
    }
    
    private func fetchMessages() {
        MessageService.fetchMessages(otherUser: otherUser) { [weak self] messages in
            self?.messages = messages
            print(messages)
            self?.collectionView.reloadData()
        }
    }
    
    private func markReadAllMsg() {
        MessageService.markReadAllMsg(otherUser: otherUser)
    }
}
    
    extension ChatViewController {
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return messages.count
        }
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.description(), for: indexPath) as! ChatCell
            let message = messages[indexPath.row]
            cell.viewModel = MessageViewModel(message: message)
            return cell
        }
    }
    
    extension ChatViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return .init(top: 15, left: 0, bottom: 15, right: 0)
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
            let cell = ChatCell(frame: frame)
            let message = messages[indexPath.row]
            cell.viewModel = MessageViewModel(message: message)
            cell.layoutIfNeeded()
            
            let targetSize = CGSize(width: view.frame.width, height: 1000)
            let estimateSize = cell.systemLayoutSizeFitting(targetSize)
            return .init(width: view.frame.width, height: estimateSize.height)
        }
    }
    
extension ChatViewController: CustomeInputDelegate {
  
        func inputView(_ view: CustomeInputView, wantUploadMessage message: String) {
            MessageService.fetchSingleRecentMsg(otherUser: otherUser) { [unowned self] unreadCount in
                MessageService.uploadMessage(message: message, currentUser: currentUser, unReadCount: unreadCount + 1, otherUser: otherUser) { error in
                    self.collectionView.reloadData()
                    
                }
            }
            view.clearTextView()
        }
    }
