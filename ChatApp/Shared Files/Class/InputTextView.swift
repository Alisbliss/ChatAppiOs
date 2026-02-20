//
//  InputTevtView.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.02.2026.
//

import UIKit

class InputTextView: UITextView {
    
    let placeholder = CustomLabel(text: "  Type a message...", labelColor: .lightGray)
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9607843137, alpha: 1)
        layer.cornerRadius = 20
        isScrollEnabled = false
        font = .systemFont(ofSize: 16)
        addSubview(placeholder)
        placeholder.centerY(inView: self, leftAnchor: leftAnchor, rightAnchor: rightAnchor, paddingLeft: 8)
        paddingView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTextDidChange() {
        placeholder.isHidden = !text.isEmpty
    }
}

extension UITextView {
    func paddingView() {
        self.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    }
}
