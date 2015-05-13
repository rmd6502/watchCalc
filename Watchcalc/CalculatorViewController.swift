//
//  CalculatorViewController.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/5/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import UIKit

class CalculatorViewController: UICollectionViewController {
    var valueLabel : UILabel?
    let buttons = ["C","√","1/x","÷","9","8","7","✕","6","5","4","-","3","2","1","+","±","0",".","=","sin","cos","tan","π","eˣ","yˣ","lnx","log","x²","x³","∛","rnd","MC","M+","M-","MR","x!","e","EE","="]
    let engine = CalcEngine.sharedCalcEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CalculatorButton", forIndexPath: indexPath) as? CalculatorButton {
            cell.buttonLabel.text = buttons[indexPath.row]
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "CalculatorValueHeader", forIndexPath: indexPath) as? CalculatorHeader {
            self.valueLabel = headerView.valueLabel
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CalculatorButton, button = cell.buttonLabel.text {
            println("selected \(button)")
            if let monomial = MonomialOperator(rawValue: button) {
                engine.handleMonomial(monomial)
            } else if let binomial = BinomialOperator(rawValue: button) {
                engine.handleBinomial(binomial)
            } else {
                switch button {
                case "0"..."9",".":
                    engine.handleOperand(button)
                case "C":
                    engine.doClear()
                case "=":
                    engine.handleEqual()
                default:
                    println("You need to write the handler for \(button)")
                }
            }
            valueLabel?.text = engine.operand
        }
    }
}

