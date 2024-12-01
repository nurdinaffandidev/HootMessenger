//
//  NewConversationsViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 19/11/24.
//

import Foundation
import Combine

class NewConversationsViewModel {
    private let service: APIServicing
    private var viewModelEvent = PassthroughSubject<ViewModelEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    var didFetchOnce = false
    var chatUsers: [[String:String]] = [[:]]
    var results: [SearchResult] = []
    
    init(service: APIServicing) {
        self.service = service
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Functions
    func fetchUsers(completion: @escaping () -> Void) {
        Task {
            do {
                chatUsers = try await service.getAllUsers()
                didFetchOnce = true
                completion()
            } catch {
                viewModelEvent.send(.fetchUsersFail)
            }
        }
    }
    
    func filterUsers(with term: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, didFetchOnce else {
            return
        }
        let safeEmail = CommonUtils.safeEmail(emailAddress: currentUserEmail)

        let results: [SearchResult] = chatUsers.filter({
            guard let email = $0["email"], email != safeEmail else { return false }
            guard let name = $0["name"]?.lowercased() else { return false }
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["email"], let name = $0["name"] else {
                return nil
            }
            return SearchResult(name: name, email: email)
        })
        self.results = results
        viewModelEvent.send(.filteredUsers)
    }
}

// MARK: Event Handling
extension NewConversationsViewModel {
    enum UIEvent {
        case viewDidLoad
        case fetchUsers(_ completion: () -> Void)
        case filterUsers(_ query: String)
    }
    
    enum ViewModelEvent {
        case fetchUsersFail
        case filteredUsers
    }
    
    func bind(_ uiEvents: AnyPublisher<UIEvent, Never>) -> AnyPublisher<ViewModelEvent, Never> {
        uiEvents.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                break
            case .fetchUsers(let completion):
                self.fetchUsers(completion: completion)
            case .filterUsers(let query):
                self.filterUsers(with: query)
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

// MARK: Search Result
struct SearchResult {
    let name: String
    let email: String
}
