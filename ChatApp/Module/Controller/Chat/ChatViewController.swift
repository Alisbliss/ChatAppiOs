//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit
import Firebase

class ChatViewController: UICollectionViewController {
    //MARK: Properties
    
    private var messages = [[Message]]()
    
    var audioStatusSubscription: Any?
    
    private lazy var customeInputView: CustomeInputView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let view = CustomeInputView(frame: frame)
        view.delegate = self
        return view
    }()
    
    private lazy var attachAlert: UIAlertController = { [weak self] in
        let alert = UIAlertController(title: "Attach File", message: "Select the button you want to attach from", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self?.handleCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self?.handleGallery()
        }))
        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: { _ in
            print("location")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    var currentUser: User
    var otherUser: User
    //MARK: LifeCircle
    init(currentUser: User,otherUser: User) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(ChatHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ChatHeader.description())
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
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    private func fetchMessages() {
        MessageService.fetchMessages(otherUser: otherUser) { [weak self] messages in
            let groupMessage = Dictionary(grouping: messages) { (element) -> String in
                let dateValue = element.timestamp.dateValue()
                let stringDate = self?.stringValue(forDate: dateValue)
                return stringDate ?? ""
            }
            self?.messages.removeAll()
            
            let sortedKeys = groupMessage.keys.sorted(by: {$0 < $1})
            sortedKeys.forEach { key in
                let values = groupMessage[key]
                self?.messages.append(values ?? [])
            }
            self?.collectionView.reloadData()
            self?.collectionView.scrollToLastItem()
        }
    }
    
    private func markReadAllMsg() {
        MessageService.markReadAllMsg(otherUser: otherUser)
    }
}
    
    extension ChatViewController {
        
        override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionHeader {
                guard let firstMessage = messages[indexPath.section].first else { return UICollectionReusableView() }
                let dateValue = firstMessage.timestamp.dateValue()
                let stringValue = stringValue(forDate: dateValue)
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChatHeader.description(), for: indexPath) as! ChatHeader
                cell.dateValue = stringValue
                return cell
            }
            return UICollectionReusableView()
        }
        override func numberOfSections(in collectionView: UICollectionView) -> Int {
            return messages.count
        }
        
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return messages[section].count
        }
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.description(), for: indexPath) as! ChatCell
            let message = messages[indexPath.section][indexPath.row]
            cell.viewModel = MessageViewModel(message: message)
            cell.delegate = self
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: view.frame.height, height: 50)
        }
    }
    
    extension ChatViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return .init(top: 15, left: 0, bottom: 15, right: 0)
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
            let cell = ChatCell(frame: frame)
            let message = messages[indexPath.section][indexPath.row]
            cell.viewModel = MessageViewModel(message: message)
            cell.layoutIfNeeded()
            
            let targetSize = CGSize(width: view.frame.width, height: 1000)
            let estimateSize = cell.systemLayoutSizeFitting(targetSize)
            return .init(width: view.frame.width, height: estimateSize.height)
        }
    }
    
extension ChatViewController: CustomeInputDelegate {
    func inputViewForAudion(_ view: CustomeInputView, audioURL: URL) {
        self.showLoader(true)
        FileUploader.uploadAudio(audioURL: audioURL) { [unowned self] audioString in
            MessageService.fetchSingleRecentMsg(otherUser: self.otherUser) { unReadCount in
                MessageService.uploadMessage(audioURL: audioString, currentUser: self.currentUser, unReadCount: unReadCount + 1, otherUser: self.otherUser) { error in
                    self.showLoader(false)
                }
            }
        }
    }
    
    func inputViewforAttach(_ view: CustomeInputView) {
        present(attachAlert, animated: true)
    }
    
    
    func inputView(_ view: CustomeInputView, wantUploadMessage message: String) {
        MessageService.fetchSingleRecentMsg(otherUser: otherUser) { [unowned self] unreadCount in
            MessageService.uploadMessage(message: message, currentUser: currentUser, unReadCount: unreadCount + 1, otherUser: otherUser) { error in
                self.collectionView.reloadData()
                
            }
        }
        view.clearTextView()
    }
}
