//
//  CustomeInputView.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit

class CustomeInputView: UIView {
    //MARK: Properties
    let infutTextView = InputTextView()
    //MARK: LifeCircle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        addSubview(infutTextView)
        infutTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 5, paddingRight: 8)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .lightGray
        addSubview(dividerView)
        dividerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    //MARK: Helpers
}
