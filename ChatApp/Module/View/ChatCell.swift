//
//  ChatCell.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit

class ChatCell: UICollectionViewCell {
    
    //MARK: Properties
    private let profileImageView = CustomImageView(width: 30, height: 30, backgroundColor: .lightGray, cornerRadius: 15)
    private let dateLabel = CustomLabel(text: "10/10/2020")
    
    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9245408177, green: 0.9278380275, blue: 0.9309870005, alpha: 1)
        return view
    }()
    
    var bubbleRightAnchor: NSLayoutConstraint!
    var bubbleLeftAnchor: NSLayoutConstraint!
    
    var dateRightAnchor: NSLayoutConstraint!
    var dateLeftAnchor: NSLayoutConstraint!
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.text = "SampleData"
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    //MARK: LifeCircle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 10)
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleLeftAnchor.isActive = false
        
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleRightAnchor.isActive = false
        
        addSubview(dateLabel)
        dateLeftAnchor = dateLabel.leftAnchor.constraint(equalTo: bubbleContainer.rightAnchor, constant: 12)
        dateLeftAnchor.isActive = false
        dateRightAnchor = dateLabel.rightAnchor.constraint(equalTo: bubbleContainer.leftAnchor, constant: -12)
        dateRightAnchor.isActive = false
        dateLabel.anchor(bottom: bottomAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Helpers
    func configure(text: String) {
        bubbleLeftAnchor.isActive = true
        dateLeftAnchor.isActive = true
        textView.text = text
    }
}
