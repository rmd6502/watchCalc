//
//  CalculatorButton.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/12/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import Foundation
import UIKit

class CalulatorGradientButton : UIButton {
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
}

class CalculatorButton : UICollectionViewCell {
    @IBOutlet weak var calcButton: CalulatorGradientButton!
}

class CalculatorHeader : UICollectionReusableView {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueLabelContainer: UIView!
    @IBOutlet weak var registerTable: UITableView!
}