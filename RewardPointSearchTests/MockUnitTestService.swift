//
//  MockUnitTestService.swift
//  RewardPointSearchTests
//
//  Created by Wayne Hsiao on 2020/4/5.
//  Copyright © 2020 Wayne Hsiao. All rights reserved.
//

import Foundation
import Combine
@testable import RewardPointSearch

class MockUnitTestService: Service {
    
    func getUserInfo(userName: String) -> AnyPublisher<Data, ServiceError> {
        print(userName)
        return Future<Data, ServiceError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                if let data = self.mockUserInfo(userName: userName) {
                    promise(.success(data))
                } else {
                    promise(.failure(.notFound))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func mockUserInfo(userName: String) -> Data? {
        let encoder = JSONEncoder()
        let splitedName = userName.split(separator: " ")
        guard let firstName = splitedName.first, String(firstName) == "Wayne",
            let lastName = splitedName.last, String(lastName) == "Hsiao" else {
                return nil
        }
        let userInfo = UserInfo(firstName: String(firstName),
                                lastName: String(lastName),
                                rewardPoints: 105)
        return try! encoder.encode(userInfo)
    }
}
