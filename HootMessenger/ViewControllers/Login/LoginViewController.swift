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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func bind() {
        viewModel.bind(uiEvents.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .loginSuccess:
                    break
                case .loginFail:
                    break
                }
            }.store(in: &cancellables)
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()
    
    
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
        title.font = .systemFont(ofSize: 30, weight: .thin)
//        title.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
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
        field.returnKeyType = .continue
        field.layer.cornerRadius = 25
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemTeal.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
        return field
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .systemTeal
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .thin)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private lazy var testSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        view.heightAnchor.constraint(equalToConstant: 500).isActive = true
        return view
    }()
    
    private lazy var spacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 1.5
        return view
    }()
    
    // MARK: - Setup
    func setup() {
        view.backgroundColor = .white
        
        mainContentStackView.addArrangedSubview(pageTitle)
        mainContentStackView.setCustomSpacing(20, after: pageTitle)
        mainContentStackView.addArrangedSubview(emailField)
        mainContentStackView.setCustomSpacing(10, after: emailField)
        mainContentStackView.addArrangedSubview(passwordField)
        mainContentStackView.setCustomSpacing(10, after: passwordField)
//        mainContentStackView.addArrangedSubview(testSpacer)
//        mainContentStackView.setCustomSpacing(10, after: testSpacer)
        mainContentStackView.addArrangedSubview(spacer)
        
        bottomContentStackView.addArrangedSubview(loginButton)
        
        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(mainContentStackView)
        contentStackView.addArrangedSubview(bottomContentStackView)
        
//        scrollView.addSubview(imageView)
//        scrollView.addSubview(mainContentStackView)
//        scrollView.addSubview(bottomContentStackView)
        
        scrollView.addSubview(contentStackView)
        
        view.addSubview(scrollView)
    }
    
    func setupLayoutConstraints() {
        let safeLayout = view.safeAreaLayoutGuide
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeLayout.snp.top)
            $0.width.equalTo(view.width)
            $0.height.equalTo(view.height)
            $0.bottom.equalTo(safeLayout.snp.bottom)
        }
        scrollView.layoutIfNeeded()
        
        mainContentStackView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(30)
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
            $0.bottom.equalTo(bottomContentStackView.snp.top)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.height.width.equalTo(100)
            $0.centerX.equalToSuperview()
        }
        
        pageTitle.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
        }
        
        bottomContentStackView.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
//            $0.bottom.equalTo(scrollView.snp.bottom)
            $0.bottom.equalTo(contentStackView.snp.bottom)
        }
    }
    
}
