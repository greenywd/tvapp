//
//  SeasonsTests.swift
//  SeasonsTests
//
//  Created by Thomas Greenwood on 13/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import XCTest

@testable import Seasons

class SeasonsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testShowDecode() throws {
        if let path = Bundle(for: type(of: self)).path(forResource: "Show", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
                decoder.userInfo[CodingUserInfoKey.context!] = PersistenceService.temporaryContext
                
                let json = try decoder.decode(Show.self, from: data)
                XCTAssertNotNil(json)
                
            } catch {
                print(error, error.localizedDescription)
                XCTFail("Failed to create data from JSON file.")
            }
        } else {
            XCTFail("Failed to retrieve JSON file.")
        }
    }
}
