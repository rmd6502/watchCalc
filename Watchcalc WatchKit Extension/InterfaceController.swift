//
//  InterfaceController.swift
//  Watchcalc WatchKit Extension
//
//  Created by Robert Diamond on 5/5/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var tableView: WKInterfaceTable!
    var value = 0.0

    var keyBindings : [[String]]!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        println("context \(context)")

        tableView.setRowTypes(["ValueRow", "ButtonRow", "ButtonRow", "ButtonRow", "ButtonRow","ButtonRow"])
        var buttonIdx = 0
        var buttonWidth = (self.contentFrame.width - 16.0) / 4.0
        for (var rowNum = 0; rowNum < tableView.numberOfRows; ++rowNum) {
            switch tableView.rowControllerAtIndex(rowNum) {
            case let valueRow as ValueRow:
                valueRow.valueLabel.setText("\(value)")
            case let buttonRow as ButtonRow:
                buttonRow.keys = self.keyBindings[buttonIdx++]
                buttonRow.buttonWidth = buttonWidth
            default:
                break
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
