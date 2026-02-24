//
//  ConversationCell.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit
import SDWebImage

class ConversationCell: UITableViewCell {
    //MARK: Properties
    var viewModel: MessageViewModel? {
        didSet {
            configure()
        }
    }
    private let profileImageView = CustomImageView(image: #imageLiteral(resourceName: "Google_Contacts_logo copy"), width: 60, height: 60, backgroundColor: .lightGray, cornerRadius: 30)
    private let fullName = CustomLabel(text: "FullName")
    private let recentMessage = CustomLabel(text: "resent message", labelColor: .lightGray)
    private let dateLabel = CustomLabel(text: "10/10/2025", labelColor: .lightGray)
    private let unreadMsgLabel: UILabel = {
        let label = UILabel()
        label.text = "7"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .red
        label.setDimensions(height: 40, width: 40)
        label.layer.cornerRadius = 20
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    
    //MARK: LifeCircle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor)
        
        let stackView = UIStackView(arrangedSubviews: [fullName, recentMessage])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        addSubview(stackView)
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 15)
        
        let stackDate = UIStackView(arrangedSubviews: [dateLabel, unreadMsgLabel])
        stackDate.axis = .vertical
        stackDate.spacing = 7
        stackDate.alignment = .trailing
        addSubview(stackDate)
        stackDate.centerY(inView: self, rightAnchor: rightAnchor, paddingRight: 10)
        //addSubview(dateLabel)
        //dateLabel.centerY(inView: self, rightAnchor: rightAnchor, paddingRight: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        self.profileImageView.sd_setImage(with: viewModel.profileImageURL)
        self.fullName.text = viewModel.fullname
        self.recentMessage.text = viewModel.messageText
        self.dateLabel.text = viewModel.timestampString
        self.unreadMsgLabel.text = "\(viewModel.unReadCount)"
        self.unreadMsgLabel.isHidden = viewModel.shouldHideUnReadLabel
    }
}
