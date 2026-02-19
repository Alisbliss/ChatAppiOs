//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 16.02.2026.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    //MARK: Properties
    var viewModel = LoginViewModel()
    
    private let welcomeLabel = CustomLabel(text: "HEY, WELCOME", labelFont: .boldSystemFont(ofSize: 20))
    
    private var profileImageView = CustomImageView(image: #imageLiteral(resourceName: "profile"), width: 50, height: 50)
    
    private let emailTF = CustomTextField(placeHolder: "Email", keyBoardType: .emailAddress)
    
    private let passwordTF = CustomTextField(placeHolder: "Password", issecureText: true)
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleLoginVC), for: .touchUpInside)
        button.blackButton(buttonText: "Login")
        return button
    }()
    
    private lazy var forgetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Forget your password?", secondString: "Get help signing in")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleForgetPassword), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Don't have an acccount?", secondString: "Sign Up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleSignUpButton), for: .touchUpInside)
        return button
    }()
    
    private let continueLabel = CustomLabel(text: "or Continue with Google", labelFont: .systemFont(ofSize: 14), labelColor: .lightGray)
    
    private lazy var googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Google", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.setDimensions(height: 50, width: 150)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(googleSignInVC), for: .touchUpInside)
        return button
    }()
    
    //MARK: LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureForTextField()
    }
    //MARK: Helpers
    func configure() {
        view.backgroundColor = .white
        
        view.addSubview(welcomeLabel)
        welcomeLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        welcomeLabel.centerX(inView: view)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: welcomeLabel.bottomAnchor, paddingTop: 20)
        profileImageView.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [emailTF, passwordTF, loginButton, forgetPasswordButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        signUpButton.centerX(inView: view)
        
        view.addSubview(continueLabel)
        continueLabel.centerX(inView: view, topAnchor: forgetPasswordButton.bottomAnchor, paddingTop: 30)
        
        view.addSubview(googleButton)
        googleButton.centerX(inView: view, topAnchor: continueLabel.bottomAnchor, paddingTop: 12)
    }
    
    private func configureForTextField() {
        emailTF.addTarget(self, action: #selector(handleTextChange(sender:)), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(handleTextChange(sender:)), for: .editingChanged)
    }
    
    @objc func handleLoginVC() {
        guard let email = emailTF.text?.lowercased() else { return }
        guard let password = passwordTF.text else { return }
        showLoader(true)
        AuthServices.loginUser(withEmail: email, withPassword: password) { [weak self] result, error in
            self?.showLoader(false)
            if let error = error {
                self?.showMessage(title: "Error", message: "\(error.localizedDescription)")
                print("Error \(error.localizedDescription)")
                return
            }
            self?.navToConversationVC()
            
        }
    }
    
    @objc func handleForgetPassword() {
        print("Forget")
    }
    @objc func handleSignUpButton() {
        let controller = RegisterViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    @objc func googleSignInVC() {
        showLoader(true)
        setupGoogle()
    }
    
    @objc func handleTextChange(sender: UITextField) {
        sender == emailTF ? (viewModel.email = sender.text) : (viewModel.password = sender.text)
        updateForm()
    }
    
    private func updateForm() {
        loginButton.isEnabled = viewModel.formValid
        loginButton.backgroundColor = viewModel.backbroundColor
        loginButton.setTitleColor(viewModel.buttonTintColor, for: .normal)
    }
    
    func navToConversationVC() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        showLoader(true)
        UserService.fetchUser(uid: uid) { [weak self] user in
            self?.showLoader(false)
            print("User \(user)")
            let vc = ConversationViewController(user: user)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true)
        }
    }
}

extension LoginViewController: RegisterVC_Delegate {
    func didSuccessCreateAccount(_ vc: RegisterViewController) {
        vc.navigationController?.popViewController(animated: true)
        navToConversationVC()
    }
}
