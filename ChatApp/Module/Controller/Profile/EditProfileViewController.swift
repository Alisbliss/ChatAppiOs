//
//  EditProfileViewController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 20.04.2026.
//

import UIKit
import SDWebImage

class EditProfileViewController: UIViewController {
    //MARK: - Properties
    private let user: User
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.setDimensions(height: 50, width: 200)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSubmitProfile), for: .touchUpInside)
        return button
    }()

    private lazy var profileImageView: CustomImageView = {
        let tao = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        let iv = CustomImageView(width: 125, height: 125, backgroundColor: .lightGray, cornerRadius: 125 / 2)
        iv.addGestureRecognizer(tao)
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let fullnameLabel = CustomLabel(text: "Fullname", labelColor: .red)
    private let fullnameText = CustomTextField(placeHolder: "fullname")
    
    private let usernameLabel = CustomLabel(text: "Username", labelColor: .red)
    private let usernameText = CustomTextField(placeHolder: "username")
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    var selectImage: UIImage?
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureProfileData()
    }
    
    //MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        title = "Edit Profile"
        
        view.addSubview(editButton)
        editButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingRight: 12)
        
        view.addSubview(profileImageView)
        profileImageView.centerX(inView: view)
        profileImageView.anchor(top: editButton.bottomAnchor, paddingTop: 10)
        
        let stackView = UIStackView(arrangedSubviews: [fullnameLabel, fullnameText, usernameLabel, usernameText])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30)
        
        fullnameText.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
        usernameText.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
    }
    
    private func configureProfileData() {
        fullnameText.text = user.fullname
        usernameText.text = user.username
        
        profileImageView.sd_setImage(with: URL(string: user.profileImageURL))
    }
    
    @objc func handleSubmitProfile() {
        guard let fullname = fullnameText.text else { return }
        guard let username = usernameText.text else { return }
        
        showLoader(true)
        if selectImage == nil {
            let params = [
                "fullname": fullname,
                "username": username
            ]
            updateUser(params: params)
        } else {
            guard let selectImage = selectImage else { return }
            FileUploader.uploadImage(image: selectImage) { [weak self] imageURL in
                guard let self else { return }
                let params = [
                    "fullname": fullname,
                    "username": username,
                    "profileImageURL": imageURL
                ]
                self.updateUser(params: params)
            }
        }
    }
  
    
    @objc func handleImageTap() {
       present(imagePicker, animated: true)
    }
    
    private func updateUser(params: [String: Any]) {
        UserService.setNewUserData(data: params) {[weak self] _ in
            guard let self else { return }
            self.showLoader(false)
            NotificationCenter.default.post(name: .userProfile, object: nil)
        }
    }
}

//MARK: - UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        self.selectImage = image
        self.profileImageView.image = image
        
        dismiss(animated: true)
    }
}
