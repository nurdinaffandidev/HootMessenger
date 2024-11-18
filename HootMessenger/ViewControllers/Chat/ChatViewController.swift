//
//  ChatViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 16/11/24.
//

import UIKit
import Combine
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoURL : String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    private var viewModel: ChatViewModel
    private var uiEvents = PassthroughSubject<ChatViewModel.UIEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var messages = [Message]()
    private let selfSender = Sender(
        photoURL: "",
        senderId: "1",
        displayName: "Joe Smith"
    )
    
    init(viewModel: ChatViewModel) {
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
                case .test:
                    break
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        messages.append(
            Message(
                sender: selfSender,
                messageId: "1",
                sentDate: .now,
                kind: .text("hello worlds message ")
            )
        )
        messages.append(
            Message(
                sender: selfSender,
                messageId: "1",
                sentDate: .now,
                kind: .text("hello worlds message,hello worlds message hello worlds message hello worlds message hello worlds message hello worlds message hello worlds message   ")
            )
        )
    }
    
    // MARK: - Setup
    func setup() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        view.backgroundColor = .red
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> any SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> any MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count 
    }
    
    
}
                                    
