//
//  ContentViewModel.swift
//  RewardPointSearch
//
//  Created by Wayne Hsiao on 2020/4/5.
//  Copyright © 2020 Wayne Hsiao. All rights reserved.
//

import Foundation
import Combine

final class ContentViewModel: ObservableObject {
    enum ViewModelError: Error {
        case fullName
        case empty
    }
    
    enum Constant {
        static let placeholder = "Full Name"
        static let fetching = "Loading"
        static let enterFullName = "Please enter full name"
        static let empty = ""
        static let title = "SwiftUI MVVM Demo"
        static let subtitle = "Search your reward points."
        static let usernameLabelText = "Username"
        static let space: Character = " "
        static let dot = "."
        case customContents([String])
    }
    
    private var service: Service
    private var userInfo: UserInfo!
    private var disposables: Set<AnyCancellable> = Set()
    private var dispasableTimer: AnyCancellable!
    
    /// Binding to View
    @Published var display = Constant.empty
    @Published var keyword = Constant.empty
    @Published var keywordPlaceholder = Constant.placeholder
    @Published var title = Constant.title
    @Published var subtitle = Constant.subtitle
    @Published var usernameLabelText = Constant.usernameLabelText

    init(service: Service = UserInfoService()) {
        self.service = service
        setupSubscriber()
    }
    
    /// Setup text field binding.
    private func setupSubscriber() {
        var dots = Constant.customContents([])
        $keyword
            .debounce(for: 0.5, scheduler: DispatchQueue.global())
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .print()
            .sink {
                self.userNameValidation($0).sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.dispasableTimer = Timer.publish(every: 0.25, on: .main, in: .default)
                            .autoconnect()
                            .map { (date: Date) -> String in
                                switch dots {
                                case .customContents(var content):
                                    if content.count == 3 {
                                        content = []
                                        dots = .customContents(content)
                                    } else {
                                        content.append(Constant.dot)
                                        dots = .customContents(content)
                                    }
                                    return content.reduce(Constant.fetching) { (result, current) -> String in
                                        result + current
                                    }
                                }
                        }
                        .assign(to: \.display, on: self)
                        self.fetchUserInfo()
                    case .failure(.empty):
                        self.display = Constant.empty
                    case .failure(.fullName):
                        self.display = Constant.enterFullName
                    }
                }) { _ in }
                    .store(in: &self.disposables)
        }
        .store(in: &disposables)
    }
    
    private func userNameValidation(_ username: String) -> AnyPublisher<Void, ViewModelError> {
            let publisher = PassthroughSubject<Void, ViewModelError>()
            if username.split(separator: Constant.space).count == 2 {
                publisher.send(completion: .finished)
            } else if username.count > 0 {
                publisher.send(completion: .failure(.fullName))
            } else {
                publisher.send(completion: .failure(.empty))
            }
        return publisher.eraseToAnyPublisher()
    }
    
    /// Get user info from service.
    private func fetchUserInfo() {
        service.getUserInfo(userName: keyword)
            .subscribe(on: DispatchQueue.global())
            .decode(type: UserInfo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.display = "Hello \(self.userInfo.firstName) \(self.userInfo.lastName), \nyou have \(self.userInfo.rewardPoints) reward points."
                case .failure(_):
                    self.display = "User \(self.keyword) not found"
                }
                self.dispasableTimer.cancel()
            }, receiveValue: { userInfo in
                self.userInfo = userInfo
            })
            .store(in: &disposables)
    }
}
