//
//  RewardPointSearchTests.swift
//  RewardPointSearchTests
//
//  Created by Wayne Hsiao on 2020/4/5.
//  Copyright © 2020 Wayne Hsiao. All rights reserved.
//

import XCTest
import Combine
@testable import RewardPointSearch

class RewardPointSearchTests: XCTestCase {
    var disposables: Set<AnyCancellable> = Set()
    let mockService = MockUnitTestService()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewModelDisplayMessage1() {
        let expectation = self.expectation(description: "Change keyword")
        let viewModel = ContentViewModel(service: mockService)
        let keyword = "Wayne"
        let display = "Please enter full name"
        viewModel.$display.sink {
            if $0 == display {
                expectation.fulfill()
            }
        }
        .store(in: &disposables)
        viewModel.username = keyword
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(viewModel.display, display)
    }
    
    func testViewModelDisplayMessage2() {
        let expectation = self.expectation(description: "Change keyword")
        let viewModel = ContentViewModel(service: mockService)
        let username = "Wayne H"
        let display = "User \(username) not found"
        viewModel.$display.sink {
            if $0 == display {
                expectation.fulfill()
            }
        }
        .store(in: &disposables)
        viewModel.username = username
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(viewModel.display, display)
    }

    func testViewModelDisplayMessage3() {
        let expectation = self.expectation(description: "Change keyword")
        let viewModel = ContentViewModel(service: mockService)
        let firstName = "Wayne"
        let lastName = "Hsiao"
        let rewardPoints = 105
        let keyword = "\(firstName) \(lastName)"
        let display = "Hello \(firstName) \(lastName), \nyou have \(rewardPoints) reward points."
        viewModel.$display.sink {
            if $0 == display {
                expectation.fulfill()
            }
        }
        .store(in: &disposables)
        viewModel.username = keyword
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(viewModel.display, display)
    }

}
