//
//  FillMainContentLayout.swift
//  FillMainLayout
//
//  Created by nurdin affandi on 28/10/24.
//

import Foundation
import UIKit

open class FillMainContentLayout: BaseLayout {
    // MARK: - Keyboard related
    open var floatBottomContentStackWhenKeyboardIsUp = false
    open var isConstrainedToSafeAreaLayoutGuide = true
    
    open var rootView: UIView {
        guard let view = view else {
            fatalError("[FillMainContentLayout] Could not find view")
        }
        return view
    }
    
    open var keyboardObservingScrollView: UIScrollView {
        return scrollView
    }
    
    open var constraints: [NSLayoutConstraint] = []
    
    // MARK: - UI
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    public let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 0
        view.insetsLayoutMarginsFromSafeArea = false
        return view
    }()
    
    public let mainContentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.insetsLayoutMarginsFromSafeArea = false
        return view
    }()
    
    public let fillerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public let bottomContentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()
    
    var scrollTopAnchorFullConstraint: NSLayoutConstraint?
    var scrollTopAnchorSafeAreaConstraint: NSLayoutConstraint?
    
    public var expandToSafeArea = false {
        didSet {
            updateTopAnchorConstraints()
        }
    }
    
    func updateTopAnchorConstraints() {
        scrollTopAnchorFullConstraint?.isActive = expandToSafeArea
        scrollTopAnchorSafeAreaConstraint?.isActive = !expandToSafeArea
    }
    
    // MARK: - Setup
    private func setupFillMainContentLayout() {
        guard let view = view else { return }
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(mainContentStackView)
        stackView.addArrangedSubview(fillerView)
        stackView.addArrangedSubview(bottomContentStackView)
    }
    
    open override func setupViews() {
        super.setupViews()
        setupFillMainContentLayout()
    }
    
    // MARK: - Layout and Constraints
    open override func setLayoutContraints() {
        super.setLayoutContraints()
        guard let view = view else { return }
        // MARK: - ScrollView contraints
        scrollTopAnchorFullConstraint = scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        scrollTopAnchorSafeAreaConstraint = isConstrainedToSafeAreaLayoutGuide ?
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor) :
        scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        updateTopAnchorConstraints()
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // MARK: - StackView contraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        /**
         Make stackView fill the entire screen, so that
         1. if content's height is less than screen height, the cta button is docked to the bottom
         2. if content's height is more that screen height, the cta button resides after the last element and user needs to scroll down to see cta button
        */
        if isConstrainedToSafeAreaLayoutGuide {
            let constraint = stackView.safeAreaLayoutGuide.heightAnchor.constraint(
                greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.heightAnchor
            )
            constraint.isActive = true
            constraints.append(constraint)
            
            let constraint2 = stackView.safeAreaLayoutGuide.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            constraint.isActive = false
            constraints.append(constraint2)
        } else {
            let constraint = stackView.heightAnchor.constraint(
                greaterThanOrEqualTo: scrollView.heightAnchor
            )
            constraint.isActive = true
            constraints.append(constraint)
            
            let constraint2 = stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            constraint.isActive = false
            constraints.append(constraint2)
        }
        
        NSLayoutConstraint.activate(constraints)
        
        // MARK: - FillerView contraints
        NSLayoutConstraint.activate([
            fillerView.topAnchor.constraint(equalTo: mainContentStackView.bottomAnchor),
            fillerView.bottomAnchor.constraint(equalTo: bottomContentStackView.topAnchor),
            fillerView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        
        if isConstrainedToSafeAreaLayoutGuide {
            NSLayoutConstraint.activate([
                fillerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                fillerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                fillerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                fillerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        
        // MARK: - BottomContentStackView contraints
        bottomContentStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        if isConstrainedToSafeAreaLayoutGuide {
            NSLayoutConstraint.activate([
                bottomContentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                bottomContentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                bottomContentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bottomContentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        
        // update padding for mainContentStackView & bottomContentStackView
        mainContentStackView.isLayoutMarginsRelativeArrangement = true
        mainContentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        bottomContentStackView.isLayoutMarginsRelativeArrangement = true
        bottomContentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

public extension ViewControllerLayoutable where LayoutType: FillMainContentLayout {
    private func requireLayout() -> FillMainContentLayout {
        guard let layout = (self.layout as? FillMainContentLayout) else {
            fatalError("Could not get FillMainContentLayout")
        }
        return layout
    }
    
    var rootView: UIView {
        return requireLayout().rootView
    }
    
    var scrollView: UIScrollView {
        return requireLayout().scrollView
    }
    
    var stackView: UIStackView {
        return requireLayout().stackView
    }
    
    var mainContentStackView: UIStackView {
        return requireLayout().mainContentStackView
    }
    
    var fillerView: UIView {
        return requireLayout().fillerView
    }
    
    var bottomContentStackView: UIStackView {
        return requireLayout().bottomContentStackView
    }
    
    var expandToSafeArea: Bool {
        get {
            return requireLayout().expandToSafeArea
        }
        set {
            requireLayout().expandToSafeArea = newValue
        }
    }
}
