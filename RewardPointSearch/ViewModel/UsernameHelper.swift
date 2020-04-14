//
//  UsernameHelper.swift
//  RewardPointSearch
//
//  Created by Wayne Hsiao on 2020/4/12.
//  Copyright © 2020 Wayne Hsiao. All rights reserved.
//

import Foundation
import Combine

class UsernameHelper {
    let request: CurrentValueSubject<String, Never>
    private(set) var result: PassthroughSubject<Data, ServiceError> = PassthroughSubject<Data, ServiceError>()
    private var disposables = Set<AnyCancellable>()
    private var service: Service
    init(request: CurrentValueSubject<String, Never>, service: Service = UserInfoService()) {
        self.request = request
        self.service = service
        self.setup()
    }
    func reqeust(_ message: String) {
        request.send(message)
    }
    func setup() {
        request
            .sink { (string) in
                self.service.getUserInfo(username: string)
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case .finished:
                            self.result.send(completion: .finished)
                        case .failure(.notFound):
                            self.result.send(completion: .failure(.notFound))
                        }
                    }) { (data) in
                        self.result.send(data)
                }
                .store(in: &self.disposables)
        }
        .store(in: &disposables)
    }
}
