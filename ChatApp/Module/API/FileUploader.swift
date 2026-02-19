//
//  FileUploader.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 18.02.2026.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

struct FileUploader {
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let uid = Auth.auth().currentUser?.uid ?? "/profileImages"
        
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/\(uid)/\(filename)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let fileURL = url?.absoluteString else { return }
                completion(fileURL)
            }
        }
    }
}
