//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 16.02.2026.
//

import UIKit
import FirebaseAuth

protocol RegisterVC_Delegate: AnyObject {
    func didSuccessCreateAccount(_ vc: RegisterViewController)
}

class RegisterViewController: UIViewController {
    
    // MARK: Properties
    weak var delegate: RegisterVC_Delegate?
    var viewModel = RegisterViewModel()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Already have an account?", secondString: "Sign Up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handdleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    private lazy var plushButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .lightGray
        button.setDimensions(height: 140, width: 140)
        button.addTarget(self, action: #selector(handlePlushButton), for: .touchUpInside)
        return button
    }()
    
    private let emailTF = CustomTextField(placeHolder: "Email", keyBoardType: .emailAddress)
    
    private let passwordTF = CustomTextField(placeHolder: "Password", issecureText: true)
    
    private let fullNameTF = CustomTextField(placeHolder: "FullName")
    
    private let userNameTF = CustomTextField(placeHolder: "UserName")
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSignUpVC), for: .touchUpInside)
        button.blackButton(buttonText: "Sign in")
        return button
    }()
    
    private var profileImage: UIImage?
    
    
    // MARK: LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureTextField()
    }
    
    // MARK: Herlpers
    func configure() {
        view.backgroundColor = .white
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        alreadyHaveAccountButton.centerX(inView: view)
        
        view.addSubview(plushButton)
        plushButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        
        let stackView = UIStackView(arrangedSubviews: [emailTF, passwordTF, fullNameTF, userNameTF, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.anchor(top: plushButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
    }
    
    private func configureTextField() {
        emailTF.addTarget(self, action: #selector(handleTextChange(sender:)), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(handleTextChange(sender:)), for: .editingChanged)
        fullNameTF.addTarget(self, action: #selector(handleTextChange(sender:)), for: .editingChanged)
        userNameTF.addTarget(self, action: #selector(handleTextChange(sender:)), for: .editingChanged)
    }
    
    @objc func handdleAlreadyHaveAccount() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handlePlushButton() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func handleSignUpVC() {
        guard let email = emailTF.text?.lowercased() else { return }
        guard let passward = passwordTF.text else { return }
        guard let username = userNameTF.text?.lowercased() else { return }
        guard let fullName = fullNameTF.text else { return }
        guard let profileImage = profileImage else { return }
        
        let credential = AuthCredential(email: email, passward: passward, username: username, fullname: fullName, profileImage: profileImage)
        showLoader(true)
        AuthServices.registerUser(credential: credential) { [weak self] error in
            self?.showLoader(false)
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        delegate?.didSuccessCreateAccount(self)
    }
    
    @objc func handleTextChange(sender: UITextField) {
        if sender == emailTF {
            viewModel.email = sender.text
        } else if sender == passwordTF {
            viewModel.password = sender.text
        } else if sender == fullNameTF {
            viewModel.fullName = sender.text
        } else {
            viewModel.userName = sender.text
        }
        updateForm()
    }
    
    private func updateForm() {
        signUpButton.isEnabled = viewModel.formValid
        signUpButton.backgroundColor = viewModel.backbroundColor
        signUpButton.setTitleColor(viewModel.buttonTintColor, for: .normal)
        
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = selectedImage
        
        plushButton.layer.cornerRadius = plushButton.frame.width / 2
        plushButton.layer.masksToBounds = true
        plushButton.layer.borderColor = UIColor.black.cgColor
        plushButton.layer.borderWidth = 2
        plushButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true, completion: nil)
    }
}
