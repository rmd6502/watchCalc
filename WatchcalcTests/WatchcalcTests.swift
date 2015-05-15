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

    func testPrecedence() {
        engine.handleButton("3")
        engine.handleButton("3")
        engine.handleButton("+")
        engine.handleButton("4")
        engine.handleButton("5")
        engine.handleButton("✕")
        engine.handleButton("6")
        engine.handleButton("7")
        engine.handleButton("yˣ")
        engine.handleButton("3")
        engine.handleButton("+")
        engine.handleButton("9")
        engine.handleButton("=")
        XCTAssertEqual(engine.value, 13534377, "Operator Precedence Fail")
    }

    func testClear() {
        engine.handleButton("3")
        engine.handleButton("3")
        engine.handleButton("+")
        engine.handleButton("4")
        engine.handleButton("5")
        engine.handleButton("✕")
        engine.handleButton("6")
        engine.handleButton("7")
        engine.handleButton("=")
        engine.handleButton("C")
        XCTAssertEqual(engine.operand, "0", "Didn't clear operand")
        engine.handleButton("2")
        engine.handleButton("+")
        engine.handleButton("7")
        engine.handleButton("=")
        XCTAssertEqual(engine.operand, "9", "Clear didn't clear operand stack")
        engine.handleButton("5")
        engine.handleButton("5")
        engine.handleButton("✕")
        engine.handleButton("7")
        engine.handleButton("2")
        engine.handleButton("C")
        engine.handleButton("2")
        engine.handleButton("2")
        engine.handleButton("=")
        XCTAssertEqual(engine.operand, "1210", "CE didn't work")
    }

    func testReset() {
        engine.resetToValue(2048)
        engine.handleButton("+")
        engine.handleButton("5")
        engine.handleButton("=")
        XCTAssertEqual(engine.value, 2053, "ResetToValue fail")
    }
}
