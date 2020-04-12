//
//  MockService.swift
//  RewardPointSearch
//
//  Created by Wayne Hsiao on 2020/4/5.
//  Copyright © 2020 Wayne Hsiao. All rights reserved.
//

import Foundation
import Combine

class MockService: Service {
    private var disposable: AnyCancellable!
    private let cache = NSCache<NSString, NSNumber>()
    func getUserInfo(username: String) -> AnyPublisher<Data, ServiceError> {
        Future<Data, ServiceError> { promise in
            let randomDelay = Int.random(in: 1...3)
            DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval(randomDelay)) {
                self.disposable = self.mockUserInfo(username: username)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(.notFound):
                            promise(.failure(.notFound))
                        }
                    }) { userInfo in
                        self.disposable = Publishers.Encode(upstream: Just(userInfo), encoder: JSONEncoder())
                            .sink(receiveCompletion: { completion in
                                switch completion {
                                case .failure(_):
                                    promise(.failure(.notFound))
                                case .finished:
                                    break
                                }
                            }) { data in
                                promise(.success(data))
                        }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    private func mockUserInfo(username: String) -> AnyPublisher<UserInfo, ServiceError> {
        return Just(username)
            .setFailureType(to: ServiceError.self)
            .map {
                $0.split(separator: " ")
        }.flatMap { (names: Array<Substring>) -> AnyPublisher<UserInfo, ServiceError> in
            if let firstName = names.first,
                let lastName = names.last {
                var rewardPoints = 0
                if let points = self.cache.object(forKey: username as NSString)?.intValue {
                    rewardPoints = points
                } else {
                    rewardPoints = Int.random(in: 200...350)
                    self.cache.setObject(NSNumber(value: rewardPoints), forKey: username as NSString)
                }
                return Just(UserInfo(firstName: String(firstName),
                                     lastName: String(lastName),
                                     rewardPoints: rewardPoints))
                    .setFailureType(to: ServiceError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: ServiceError.notFound)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}
