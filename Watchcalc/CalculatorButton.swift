//
//  CalculatorButton.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/12/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import Foundation
import UIKit

class CalculatorButton : UICollectionViewCell {
    @IBOutlet weak var buttonLabel: UILabel!
}

class CalculatorHeader : UICollectionReusableView {
    @IBOutlet weak var valueLabel: UILabel!
}