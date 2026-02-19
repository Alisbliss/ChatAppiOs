//
//  VC.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 19.02.2026.
//

import UIKit
import JGProgressHUD
import SDWebImage

extension UIViewController {
    static let hud = JGProgressHUD(style: .dark)
    
    func showLoader(_ show: Bool) {
        view.endEditing(true)
        
        if show {
            UIViewController.hud.show(in: view)
        } else {
            UIViewController.hud.dismiss()
        }
    }
    
    func showMessage(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func getImage(withImageURL imageURL: URL, completion: @escaping(UIImage) -> Void) {
        SDWebImageManager.shared.loadImage(with: imageURL as URL?, options: .continueInBackground, progress: nil) { [weak self] image, data, error, cashType, finished, url in
            if let error = error {
                self?.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard let image = image else { return }
            completion(image)
        }
    }
}
