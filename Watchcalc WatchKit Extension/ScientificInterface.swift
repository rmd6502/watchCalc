//
//  ScientificInterface.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/6/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import Foundation
import WatchKit

class ScientificInterface : InterfaceController {

    @IBOutlet weak var scientificTable: WKInterfaceTable!

    let scientificKeyBindings = [["sin","cos","tan","π"],["eˣ","yˣ","lnx","log"],["x²","x³","∛","rnd"],["MC","M+","M-","MR"],["x!","e","EE","="]]

    override func awakeWithContext(context: AnyObject?) {
        self.tableView = scientificTable
        self.keyBindings = scientificKeyBindings
        super.awakeWithContext(context)
    }
}