//
//  BaseTabBarController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 6/11/24.
//

import UIKit
import Combine

class BaseTabBarController: UITabBarController {
    private var viewModel: BaseTabBarViewModel
    private var uiEvents = PassthroughSubject<BaseTabBarViewModel.UIEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: BaseTabBarViewModel) {
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
                case .validationSuccess:
                    break
                case .validationFail:
                    uiEvents.send(.presentLoginScreen)
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showOverlayView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uiEvents.send(.viewDidAppear)
        
    }
    
    private lazy var overlayPage: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemTeal
        return view
    }()
    
    private lazy var overlayPageTitle: OverlayLabel = {
        let view = OverlayLabel()
        view.drawText(in: CGRect().inset(by: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 10,
            right: 0
        )))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.text = "Hoot Messenger"
        view.font = UIFont(name: "SignPainter", size: 50)
        view.textAlignment = .center
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var overlayImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "message.circle")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .white
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return view
    }()
    
    func showOverlayView() {
        overlayPage.addSubview(overlayImageView)
        overlayPage.addSubview(overlayPageTitle)
        view.addSubview(overlayPage)
        
        overlayImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-150)
        }
        
        overlayPageTitle.snp.makeConstraints {
            $0.top.equalTo(overlayImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        overlayPage.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview()
        }
    }
}
