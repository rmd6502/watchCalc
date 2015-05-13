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
            cell.calcButton.setTitle(buttons[indexPath.row], forState: UIControlState.Normal)
            if let layer = cell.calcButton.layer as? CAGradientLayer {
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
            headerView.valueLabelContainer.layer.cornerRadius = 6
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }

    // MARK: Collection View Delegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CalculatorButton, button = cell.calcButton.titleLabel?.text {
            println("selected \(button)")

            engine.handleButton(button)
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

    @IBAction func buttonTouched(sender: CalulatorGradientButton) {
        sender.backgroundColor = UIColor.grayColor()
    }

    @IBAction func buttonTouchCancel(sender: CalulatorGradientButton) {
        sender.backgroundColor = UIColor.darkGrayColor()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if let button = sender.titleLabel?.text {
            println("selected \(button)")
            UIView.animateWithDuration(0.125, animations: { () -> Void in
                sender.backgroundColor = UIColor.darkGrayColor()
            })

            engine.handleButton(button)
            valueLabel?.text = engine.operand
        }
    }
}

