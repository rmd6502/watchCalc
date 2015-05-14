//
//  WatchcalcTests.swift
//  WatchcalcTests
//
//  Created by Robert Diamond on 5/5/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import UIKit
import XCTest

class WatchcalcTests: XCTestCase {
    var engine = CalcEngine.sharedCalcEngine()

    override func setUp() {
        super.setUp()
        engine.allClear()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimple() {
        engine.handleButton("3")
        engine.handleButton("3")
        engine.handleButton("+")
        engine.handleButton("4")
        engine.handleButton("5")
        engine.handleButton("✕")
        engine.handleButton("6")
        engine.handleButton("7")
        engine.handleButton("=")
        XCTAssertEqual(engine.value, 3048, "Operator Precedence Fail")
        engine.handleButton("-")
        engine.handleButton("8")
        engine.handleButton("=")
        XCTAssertEqual(engine.value, 3040, "value stack Fail")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
