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
        flowLayout.sectionInset = UIEdgeInsets(top: 5.0, left: 2.0, bottom: 5.0, right: 2.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: View Controller
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.collectionView?.reloadData()
    }

    // MARK: Collection View Data Source
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CalculatorButton", forIndexPath: indexPath) as? CalculatorButton {
            cell.layer.cornerRadius = 6
            cell.buttonLabel.text = buttons[indexPath.row]
            if let layer = cell.layer as? CAGradientLayer {
                let gradientColors = [UIColor.grayColor().colorWithAlphaComponent(0.6).CGColor, UIColor.whiteColor().colorWithAlphaComponent(0.4).CGColor, UIColor.darkGrayColor().colorWithAlphaComponent(0.5).CGColor]
                let gradientOffsets = [0.0, 0.1, 0.9]
                layer.startPoint = CGPoint(x: 0.4, y: -0.15)
                layer.endPoint = CGPoint(x: 0.7, y: 1.0)
                layer.locations = gradientOffsets
                layer.colors = gradientColors
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "CalculatorValueHeader", forIndexPath: indexPath) as? CalculatorHeader {
            self.valueLabel = headerView.valueLabel
            headerView.valueLabel.layer.cornerRadius = 10
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
        let height = (self.view.bounds.height - 5.0) / numRows - 2 * flowLayout.minimumLineSpacing
        return CGSize(width: width, height: height)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        println("size \(self.view.frame)")
        let width = self.view.bounds.width - 10.0
        let height = CGFloat(60.0)

        return CGSize(width: width, height: height)
    }
}

