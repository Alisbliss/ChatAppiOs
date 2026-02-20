//
//  UserCellTableViewCell.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit

class UserCell: UITableViewCell {

    //MARK: Properties
    private let profileImageView = CustomImageView(width: 48, height: 48, backgroundColor: .lightGray, cornerRadius: 24)
    
    private let username = CustomLabel(text: "Username", labelFont: .systemFont(ofSize: 17))
    private let fullname = CustomLabel(text: "Fullname", labelColor: .lightGray)
    //MARK: LifeCircle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor)
        
        let stackView = UIStackView(arrangedSubviews: [username, fullname])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        addSubview(stackView)
        stackView.centerY(inView: self, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Helpers

}
