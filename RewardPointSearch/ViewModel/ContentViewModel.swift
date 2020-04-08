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
    private var disposableTimer: AnyCancellable!
    /// Binding to View
    @Published var display = Constant.empty
    @Published var username = Constant.empty
    @Published var usernamePlaceholder = Constant.placeholder
    @Published var title = Constant.title
    @Published var subtitle = Constant.subtitle
    @Published var usernameLabelText = Constant.usernameLabelText
    let servicePublisher = PassthroughSubject<AnyPublisher<Data, ServiceError>, ServiceError>()
    init(service: Service = UserInfoService()) {
        self.service = service
        $username
            .debounce(for: 0.5, scheduler: DispatchQueue.global())
            .flatMap { (username) -> AnyPublisher<String, Never> in
                if username.split(separator: Constant.space).count == 2 {
                    return Just(username)
                        .eraseToAnyPublisher()
                } else if username.count > 0 {
                    return Just(Constant.enterFullName)
                        .eraseToAnyPublisher()
                } else {
                    return Just(Constant.empty)
                        .eraseToAnyPublisher()
                }
        }
        .flatMap({ (message) -> AnyPublisher<String, Never> in
            switch message {
            case Constant.enterFullName, Constant.empty:
                return Just(message).eraseToAnyPublisher()
            default:
                // Loading indicator
                self.disposableTimer = self.loadingIdicator()
                    .receive(on: DispatchQueue.main)
                    .assign(to: \.display, on: self)
                // Completion message publisher
                let completionMessage = self.completionMessage()
                self.servicePublisher.send(self.service.getUserInfo(username: message))
                return completionMessage
            }
        })
            .receive(on: DispatchQueue.main)
            .assign(to: \.display, on: self)
            .store(in: &disposables)
    }
    private func completionMessage() -> AnyPublisher<String, Never> {
        return self.servicePublisher
            .switchToLatest()
            .subscribe(on: DispatchQueue.global())
            .decode(type: UserInfo.self, decoder: JSONDecoder())
            .catch { _ -> AnyPublisher<UserInfo, Never> in
                let user = UserInfo(firstName: "", lastName: "", rewardPoints: 0)
                return Just(user).eraseToAnyPublisher()
        }
        .flatMap({ (userInfo) -> AnyPublisher<String, Never> in
            self.disposableTimer.cancel()
            if userInfo.firstName != "", userInfo.lastName != "" {
                return Just("Hello \(userInfo.firstName) \(userInfo.lastName), \nyou have \(userInfo.rewardPoints) reward points.")
                    .eraseToAnyPublisher()
            } else {
                return Just("Not Found").eraseToAnyPublisher()
            }
        })
            .eraseToAnyPublisher()
    }
    private func loadingIdicator() -> AnyPublisher<String, Never> {
        var dots = Constant.customContents([])
        return Timer.publish(every: 0.25, on: .main, in: .default)
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
    }
}
