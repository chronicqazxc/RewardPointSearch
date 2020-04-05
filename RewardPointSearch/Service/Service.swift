//
//  Service.swift
//  RewardPointSearch
//
//  Created by Wayne Hsiao on 2020/4/5.
//  Copyright © 2020 Wayne Hsiao. All rights reserved.
//

import Foundation
import Combine

enum ServiceError: Error {
    case notFound
}

protocol Service {
    func getUserInfo(userName: String) -> AnyPublisher<Data, ServiceError>
}

class UserInfoService: Service {
    func getUserInfo(userName: String) -> AnyPublisher<Data, ServiceError> {
        Fail<Data, ServiceError>(error: .notFound).eraseToAnyPublisher()
    }
}
