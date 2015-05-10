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

    let scientificKeyBindings = [["sin","cos","tan","π"],["eⁿ","xⁿ","lnx","log10"],["6","5","4","-"],["3","2","1","+"],["±","0",".","="]]

    override func awakeWithContext(context: AnyObject?) {
        self.tableView = scientificTable
        self.keyBindings = scientificKeyBindings
        super.awakeWithContext(context)
    }
}