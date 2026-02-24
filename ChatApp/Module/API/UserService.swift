//
//  UserService.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 19.02.2026.
//

import Foundation
import Firebase

struct UserService {
    static func fetchUser(uid: String, completion: @escaping (User) -> Void) {
        Collection_User.document(uid).getDocument { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        Collection_User.getDocuments() { snapshot, error in
            guard let snapshot = snapshot else { return }
            let users = snapshot.documents.map({User(dictionary: $0.data())})
            completion(users)
        }
    }
}
