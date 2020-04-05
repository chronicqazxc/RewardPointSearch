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
    
    let cache = NSCache<NSString, NSNumber>()
    
    func getUserInfo(userName: String) -> AnyPublisher<Data, ServiceError> {
        Future<Data, ServiceError> { promise in
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
        guard let firstName = splitedName.first,
            let lastName = splitedName.last else {
                return nil
        }
        var rewardPoints = 0
        if let rewardPointsNumber = cache.object(forKey: userName as NSString) {
            rewardPoints = rewardPointsNumber.intValue
        } else {
            let number = NSNumber(value: Int.random(in: 200...350))
            cache.setObject(number, forKey: userName as NSString)
            rewardPoints = number.intValue
        }
        let userInfo = UserInfo(firstName: String(firstName),
                                lastName: String(lastName),
                                rewardPoints: rewardPoints)
        return try! encoder.encode(userInfo)
    }
}
