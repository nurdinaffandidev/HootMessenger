//
//  LoginViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 24/10/24.
//

import Foundation
import UIKit
import Combine
import SnapKit
import GoogleSignIn

final class LoginViewController: UIViewController {
    private var viewModel: LoginViewModel
    private var uiEvents = PassthroughSubject<LoginViewModel.UIEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupLayoutConstraints()
    }
    
    private func bind() {
        viewModel.bind(uiEvents.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .loginSuccess:
                    uiEvents.send(.routeToConversationsScreen)
                case .loginFail:
                    self.alertUserLoginError(message: "Error logging in")
                case .googleSignInFail:
                    self.alertUserLoginError(message: "Error signing in via Google")
                }
            }.store(in: &cancellables)
    }
    
    private lazy var mainContentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        return view
    }()
    
    private lazy var bottomContentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        return view
    }()
    
    private lazy var pageTitle: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Log in"
        title.font = UIFont(name: "TrebuchetMS", size: 30)
        title.textAlignment = .center
        return title
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "message.circle.fill")?.withRenderingMode(.alwaysTemplate)
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemTeal
        return imageView
    }()

    private lazy var emailField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 25
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemTeal.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
        field.delegate = self
        return field
    }()

    private lazy var passwordField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 25
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemTeal.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
        field.delegate = self
        return field
    }()
    
    private lazy var divider: PageDivider = {
        let view = PageDivider()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    private lazy var signInGoogleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Sign in with Google:"
        label.font = UIFont(name: "TrebuchetMS", size: 14)
        return label
    }()
    
    private lazy var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(didTapGoogleLogin), for: .touchUpInside)
        return button
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.systemTeal, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.systemTeal.cgColor
        button.layer.borderWidth = 2
        button.titleLabel?.font = UIFont(name: "TrebuchetMS", size: 20)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemTeal
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "TrebuchetMS", size: 20)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup
    func setup() {
        view.backgroundColor = .white
        
        mainContentStackView.addArrangedSubview(pageTitle)
        mainContentStackView.setCustomSpacing(20, after: pageTitle)
        mainContentStackView.addArrangedSubview(emailField)
        mainContentStackView.setCustomSpacing(10, after: emailField)
        mainContentStackView.addArrangedSubview(passwordField)
        mainContentStackView.setCustomSpacing(20, after: passwordField)
        mainContentStackView.addArrangedSubview(divider)
        mainContentStackView.setCustomSpacing(20, after: divider)
        mainContentStackView.addArrangedSubview(signInGoogleLabel)
        mainContentStackView.setCustomSpacing(6, after: signInGoogleLabel)
        mainContentStackView.addArrangedSubview(googleSignInButton)
        
        bottomContentStackView.addArrangedSubview(loginButton)
        bottomContentStackView.setCustomSpacing(8, after: loginButton)
        bottomContentStackView.addArrangedSubview(registerButton)
        
        view.addSubview(imageView)
        view.addSubview(mainContentStackView)
        view.addSubview(bottomContentStackView)
    }
    
    // MARK: - Layout Constraints
    func setupLayoutConstraints() {
        let safeLayout = view.safeAreaLayoutGuide
        imageView.snp.makeConstraints {
            $0.top.equalTo(safeLayout.snp.top).offset(30)
            $0.height.width.equalTo(100)
            $0.centerX.equalToSuperview()
        }
        
        mainContentStackView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(30)
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
        }
        
        bottomContentStackView.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
            $0.bottom.equalTo(safeLayout.snp.bottom)
        }
    }
    
    // MARK: - Functions
    @objc private func didTapRegister() {
        uiEvents.send(.registerButtonPressed)
    }
    
    @objc private func didTapLogin() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, 
              let password = passwordField.text,
              !email.isEmpty, !password.isEmpty,
              password.count >= 6 else {
                alertUserLoginError()
                return
        }
        uiEvents.send(.submitLoginDetails(email: email, password: password))
    }
    
    @objc private func didTapGoogleLogin() {
        uiEvents.send(.performGoogleSignIn(self))
    }
    
    // MARK: - Alerts
    func alertUserLoginError(message: String = "Please enter all information to log in.") {
        let alert = UIAlertController(
            title: "Woops",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title:"Dismiss",
                style: .cancel,
                handler: nil
            )
        )
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
