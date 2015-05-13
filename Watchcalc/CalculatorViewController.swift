//
//  CalculatorViewController.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/5/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import UIKit

class CalculatorViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var valueLabel : UILabel?
    let buttons = ["C","√","1/x","÷","9","8","7","✕","6","5","4","-","3","2","1","+","±","0",".","=","sin","cos","tan","π","eˣ","yˣ","lnx","log","x²","x³","∛","rnd","MC","M+","M-","MR","x!","e","EE","="]
    let engine = CalcEngine.sharedCalcEngine()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumInteritemSpacing = 3.0
        flowLayout.minimumLineSpacing = 6.0
        flowLayout.sectionInset = UIEdgeInsets(top: 5.0, left: 2.0, bottom: 0.0, right: 2.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Collection View Data Source
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

    // MARK: Collection View Delegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CalculatorButton, button = cell.buttonLabel.text {
            println("selected \(button)")
            cell.backgroundColor = UIColor.blueColor()
            UIView.animateWithDuration(0.125, animations: { () -> Void in
                cell.backgroundColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
                cell.buttonLabel.highlighted = false
            })
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

    // MARK: Flow Layout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        let width = self.view.bounds.width / 4.0 - 2 * flowLayout.minimumInteritemSpacing
        let numRows = CGFloat(buttons.count) / 4.0
        let height = self.view.bounds.height / numRows - 2 * flowLayout.minimumLineSpacing
        return CGSize(width: width, height: height)
    }
}

