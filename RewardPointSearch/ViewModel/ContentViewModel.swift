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
    @Published private var userInfo: UserInfo = UserInfo(firstName: "", lastName: "", rewardPoints: 0)
    private var disposables: Set<AnyCancellable> = Set()
    private var dispasableTimer: AnyCancellable!
    /// Binding to View
    @Published var display = Constant.empty
    @Published var username = Constant.empty
    @Published var usernamePlaceholder = Constant.placeholder
    @Published var title = Constant.title
    @Published var subtitle = Constant.subtitle
    @Published var usernameLabelText = Constant.usernameLabelText
    
    init(service: Service = UserInfoService()) {
        self.service = service
        // Start username validation and retrieve user info whenever username changes.
        $username
            .debounce(for: 0.5, scheduler: DispatchQueue.global())
            .sink { keyword in
                
                // Update display based on the current username.
                self.dispasableTimer = self.displayAfterValidate(username: keyword)
                    .receive(on: DispatchQueue.main)
                    .assign(to: \.display, on: self)
                
                // Username validation result.
                self.userNameValidation(keyword)
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case .finished:
                            // Retrieve user info if the username is valide.
                            self.latestUserInfo()
                                .receive(on: DispatchQueue.main)
                                .assign(to: \.userInfo, on: self)
                                .store(in: &self.disposables)
                        case .failure(.empty), .failure(.fullName):
                            break
                        }
                    }, receiveValue: { _ in })
                    .store(in: &self.disposables)
        }
        .store(in: &disposables)
        
        // Update display whenever the user info chages.
        $userInfo
            .flatMap { (userInfo) -> AnyPublisher<String, Never> in
                self.dispasableTimer?.cancel()
                if userInfo.firstName == "", userInfo.lastName == "" {
                    return Just("User \(self.username) not found")
                        .setFailureType(to: Never.self)
                        .eraseToAnyPublisher()
                } else {
                    return Just("Hello \(userInfo.firstName) \(userInfo.lastName), \nyou have \(userInfo.rewardPoints) reward points.")
                        .setFailureType(to: Never.self)
                        .eraseToAnyPublisher()
                }
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.display, on: self)
        .store(in: &disposables)
    }
    
    private func latestUserInfo() -> AnyPublisher<UserInfo, Never> {
        service.getUserInfo(userName: username)
            .subscribe(on: DispatchQueue.global())
            .decode(type: UserInfo.self, decoder: JSONDecoder())
            .catch {_ in
                Just(UserInfo(firstName: "", lastName: "", rewardPoints: 0))
                    .setFailureType(to: Never.self)
        }
        .flatMap {
            Just($0)
                .setFailureType(to: Never.self)
        }
        .eraseToAnyPublisher()
    }
    
    private func displayAfterValidate(username: String) -> AnyPublisher<String, Never> {
        var dots = Constant.customContents([])
        return Deferred { () -> AnyPublisher<String, Never> in
            var anyPublisher: AnyPublisher<String, Never>!
            self.userNameValidation(username)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        anyPublisher = Timer.publish(every: 0.25, on: .main, in: .default)
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
                        .eraseToAnyPublisher()
                    case .failure(.empty):
                        anyPublisher = Just(Constant.empty)
                            .setFailureType(to: Never.self)
                            .eraseToAnyPublisher()
                    case .failure(.fullName):
                        anyPublisher = Just(Constant.enterFullName)
                            .setFailureType(to: Never.self)
                            .eraseToAnyPublisher()
                    }
                }, receiveValue: { _ in })
                .store(in: &self.disposables)
            return anyPublisher
        }
        .eraseToAnyPublisher()
    }
    
    private func userNameValidation(_ username: String) -> PassthroughSubject<String, ViewModelError> {
        let publisher = PassthroughSubject<String, ViewModelError>()
        if username.split(separator: Constant.space).count == 2 {
            publisher.send(completion: .finished)
        } else if username.count > 0 {
            publisher.send(completion: .failure(.fullName))
        } else {
            publisher.send(completion: .failure(.empty))
        }
        return publisher
    }
}
