//
//  RegisterViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 24/10/24.
//

import Foundation
import UIKit
import Combine
import SnapKit

final class RegisterViewController: FillMainContentViewController {
    private var viewModel: RegisterViewModel
    private var uiEvents = PassthroughSubject<RegisterViewModel.UIEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel.bind(uiEvents.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .registerSuccess:
                    break
                case .registerFail:
                    break
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupLayoutConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // to make imageView circle
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
    }
    
    private lazy var topSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return view
    }()
    
    private lazy var imageWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return view
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.badge.plus")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemTeal
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        return imageView
    }()
    
    private lazy var pageTitle: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Register"
        title.font = UIFont(name: "TrebuchetMS", size: 30)
        title.textAlignment = .center
        return title
    }()
    
    private lazy var firstNameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 25
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemTeal.cgColor
        field.placeholder = "First name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
        field.delegate = self
        return field
    }()
    
    private lazy var lastNameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 25
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemTeal.cgColor
        field.placeholder = "Last name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
        field.delegate = self
        return field
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
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = .systemTeal
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "TrebuchetMS", size: 20)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Back", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.systemTeal, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "TrebuchetMS", size: 20)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .white
        scrollView.isUserInteractionEnabled = true
        
        imageWrapper.addSubview(imageView)
        
        mainContentStackView.addArrangedSubview(topSpacer)
        mainContentStackView.addArrangedSubview(imageWrapper)
        mainContentStackView.setCustomSpacing(10, after: imageWrapper)
        mainContentStackView.addArrangedSubview(pageTitle)
        mainContentStackView.setCustomSpacing(20, after: pageTitle)
        mainContentStackView.addArrangedSubview(firstNameField)
        mainContentStackView.setCustomSpacing(10, after: firstNameField)
        mainContentStackView.addArrangedSubview(lastNameField)
        mainContentStackView.setCustomSpacing(10, after: lastNameField)
        mainContentStackView.addArrangedSubview(emailField)
        mainContentStackView.setCustomSpacing(10, after: emailField)
        mainContentStackView.addArrangedSubview(passwordField)
        mainContentStackView.setCustomSpacing(10, after: passwordField)
        
        bottomContentStackView.addArrangedSubview(submitButton)
        bottomContentStackView.setCustomSpacing(8, after: submitButton)
        bottomContentStackView.addArrangedSubview(backButton)
                
    }
    
    // MARK: - Layout Constraints
    private func setupLayoutConstraints() {
        let margins = view.layoutMarginsGuide
        topSpacer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        imageWrapper.snp.makeConstraints {
            $0.leading.equalTo(margins.snp.leading)
            $0.trailing.equalTo(margins.snp.trailing)
        }
        
        imageView.snp.makeConstraints {
            $0.height.centerX.centerY.equalToSuperview()
            $0.width.equalTo(imageWrapper.snp.height)
        }
        
        pageTitle.snp.makeConstraints {
            $0.leading.equalTo(margins.snp.leading)
            $0.trailing.equalTo(margins.snp.trailing)
        }
        
        firstNameField.snp.makeConstraints {
            $0.leading.equalTo(margins.snp.leading)
            $0.trailing.equalTo(margins.snp.trailing)
        }
        
        lastNameField.snp.makeConstraints {
            $0.leading.equalTo(margins.snp.leading)
            $0.trailing.equalTo(margins.snp.trailing)
        }
        
        emailField.snp.makeConstraints {
            $0.leading.equalTo(margins.snp.leading)
            $0.trailing.equalTo(margins.snp.trailing)
        }
        
        passwordField.snp.makeConstraints {
            $0.leading.equalTo(margins.snp.leading)
            $0.trailing.equalTo(margins.snp.trailing)
        }
    }
    
    // MARK: - Functions
    @objc private func didTapChangeProfilePic() {
        presentPhotoPickerActionSheet()
    }
    
    @objc private func didTapBack() {
        uiEvents.send(.backButtonPressed)
    }
    
    @objc private func didTapSubmit() {
        
    }
}

// MARK: - Photo Picker
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoPickerActionSheet() {
        let actionSheet = UIAlertController(
            title: "Profile Picture",
            message: "How would you like to select a picture?",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Take Photo",
                style: .default,
                handler: { [weak self] _ in
                    self?.presentCamera()
                }
            )
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Choose Photo",
                style: .default,
                handler: { [weak self] _ in
                    self?.presentPhotoPicker()
                }
            )
        )
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let viewController = UIImagePickerController()
        viewController.sourceType = .camera
        viewController.delegate = self
        viewController.allowsEditing = true
        present(viewController, animated: true)
    }
    
    func presentPhotoPicker() {
        let viewController = UIImagePickerController()
        viewController.sourceType = .photoLibrary
        viewController.delegate = self
        viewController.allowsEditing = true
        present(viewController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
