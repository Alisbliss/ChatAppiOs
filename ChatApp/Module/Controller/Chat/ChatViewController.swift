//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit

class ChatViewController: UICollectionViewController {
    //MARK: Properties
    private var messages: [String] = ["hello", "How are you", " What is going on? Don't expect you so early. Come on. What is it."]
    
    private lazy var customeInputView: CustomeInputView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let view = CustomeInputView(frame: frame)
        return view
    }()
    //MARK: LifeCircle
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override var inputAccessoryView: UIView?{
        get {return customeInputView}
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: Helpers
    func configure() {
        collectionView.backgroundColor = .white
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.description())
    }
}

extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.description(), for: indexPath) as! ChatCell
        let text = messages[indexPath.row]
        cell.configure(text: text)
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
        let text = messages[indexPath.row]
        cell.configure(text: text)
        cell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimateSize = cell.systemLayoutSizeFitting(targetSize)
        return .init(width: view.frame.width, height: estimateSize.height)
    }
}
