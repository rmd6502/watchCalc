//
//  ButtonRow.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/5/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import Foundation
import WatchKit

class ButtonRow : NSObject {
    @IBOutlet weak var mainGroup: WKInterfaceGroup!
    var buttonPressedBlock : ((String) -> ())?
    @IBOutlet weak var button0Label: WKInterfaceLabel!
    @IBOutlet weak var button1Label: WKInterfaceLabel!
    @IBOutlet weak var button2Label: WKInterfaceLabel!
    @IBOutlet weak var button3Label: WKInterfaceLabel!

    var keys : [String]! {
        didSet {
            if (keys != nil) {
                // sort of like Duff's device
                switch keys.count {
                case let count where count >= 4:
                    button3Label.setText(keys[3])
                    fallthrough
                case 3:
                    button2Label.setText(keys[2])
                    fallthrough
                case 2:
                    button1Label.setText(keys[1])
                    fallthrough
                case 1:
                    button0Label.setText(keys[0])
                default:
                    break
                }
            }
        }
    }

    var buttonWidth : CGFloat! {
        didSet {
            button0.setWidth(buttonWidth)
            button1.setWidth(buttonWidth)
            button2.setWidth(buttonWidth)
            button3.setWidth(buttonWidth)
        }
    }

    @IBOutlet weak var button0: WKInterfaceButton!
    @IBOutlet weak var button1: WKInterfaceButton!
    @IBOutlet weak var button2: WKInterfaceButton!
    @IBOutlet weak var button3: WKInterfaceButton!

    @IBAction func handleButton0() {
        buttonPressedBlock?(keys[0])
    }

    @IBAction func handleButton1() {
        buttonPressedBlock?(keys[1])
    }

    @IBAction func handleButton2() {
        buttonPressedBlock?(keys[2])
    }

    @IBAction func handleButton3() {
        buttonPressedBlock?(keys[3])
    }
}
