//
//  UserInfo.swift
//  RewardPointSearch
//
//  Created by Wayne Hsiao on 2020/4/5.
//  Copyright © 2020 Wayne Hsiao. All rights reserved.
//

import Foundation
import Combine

final class UserInfo: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var rewardPoints: Int
    
    init(firstName: String = "", lastName: String = "", rewardPoints: Int = 0) {
        self.firstName = firstName
        self.lastName = lastName
        self.rewardPoints = rewardPoints
    }
}

extension UserInfo: Codable {
    enum CodingKeys: CodingKey {
        case firstName
        case lastName
        case rewardPoints
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let firstName = try container.decode(String.self, forKey: .firstName)
        let lastName = try container.decode(String.self, forKey: .lastName)
        let rewardPoints = try container.decode(Int.self, forKey: .rewardPoints)
        self.init(firstName: firstName, lastName: lastName, rewardPoints: rewardPoints)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(rewardPoints, forKey: .rewardPoints)
    }
}
