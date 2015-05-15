//
//  BasicInterface.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/6/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import Foundation
import WatchKit

class BasicInterface : InterfaceController {

    @IBOutlet weak var basicTable: WKInterfaceTable!
    
    let basicKeyBindings = [["C","√","1/x","÷"],["7","8","9","✕"],["4","5","6","-"],["1","2","3","+"],["±","0",".","="]]
    
    override func awakeWithContext(context: AnyObject?) {
        self.tableView = basicTable
        self.keyBindings = basicKeyBindings
        super.awakeWithContext(context)
    }
}