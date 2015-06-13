//
//  CalculatorViewController.swift
//  Watchcalc
//
//  Created by Robert Diamond on 5/5/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

import UIKit
import WatchConnectivity

class CalculatorViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CalcEngineDelegate, UITableViewDataSource, UITableViewDelegate {
    var valueLabel : UILabel?
    var registerTable : UITableView?
    let buttons = ["C","√","1/x","÷","7","8","9","✕","4","5","6","-","1","2","3","+","±","0",".","=","sin","cos","tan","π","eˣ","yˣ","lnx","log","x²","x³","∛","rnd","MC","M+","M-","MR","x!","e","EE","Register"]
    let engine = CalcEngine.sharedCalcEngine()

    var operatorButtonColor = UIColor(red: 31.0/255.0, green: 33.0/255.0, blue: 36.0/255.0, alpha: 1.0)
    var operandButtonColor = UIColor.grayColor()
    var scientificButtonColor = UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1.0)
    var equalButtonColor = UIColor(red: 0.4, green: 0.3, blue: 0.1, alpha: 1.0)
    var clearButtonColor = UIColor(red: 0.6, green: 0.1, blue: 0.1, alpha: 1.0)

    var darwinNotificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
    var sharedDefaults : NSUserDefaults!

    let displayClosedHeight : CGFloat = 60.0
    let displayOpenHeight : CGFloat = 360.0
    var displayHeight : CGFloat = 0.0
    var displayHeader : UIView!

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedDefaults = NSUserDefaults(suiteName: "group.com.robertdiamond.watchscicalc")
        if let storedValue = sharedDefaults?.doubleForKey("value") {
            engine.resetToValue(storedValue)
        }
        if let storedValue = sharedDefaults?.doubleForKey("memory") {
            engine.memoryValue = storedValue
        }
        displayHeight = displayClosedHeight
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        engine.valueDigits = 16
        engine.delegate = self
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
            cell.calcButton.backgroundColor = buttonColorForButton(buttons[indexPath.row])
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
            displayHeader = headerView
            self.valueLabel = headerView.valueLabel
            headerView.valueLabelContainer.layer.cornerRadius = 6
            self.registerTable = headerView.registerTable
            self.registerTable?.dataSource = self
            self.registerTable?.delegate = self
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }

    // MARK: Collection View Delegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CalculatorButton, button = cell.calcButton.titleLabel?.text {
            print("selected \(button)")

            engine.handleButton(button)
        }
    }

    // MARK: Table View Delegate (Register TableView)
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return engine.register.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        cell = tableView.dequeueReusableCellWithIdentifier("RegisterCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "RegisterCell")
            cell?.textLabel?.textColor = UIColor.whiteColor()
            cell?.detailTextLabel?.textColor = UIColor.lightGrayColor()
            cell?.backgroundColor = UIColor.clearColor()
        }

        let register = engine.register[indexPath.row]
        if register.op2 == nil {
            cell?.textLabel?.text = "\(register.operation) \(register.op1)"
        } else {
            cell?.textLabel?.text = "\(register.op1) \(register.operation) \(register.op2!)"
        }
        cell?.detailTextLabel?.text = "\(register.result)"

        return cell!
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
        //println("size \(self.view.frame)")
        let width = self.view.bounds.width - 10.0
        let height = CGFloat(displayHeight)

        return CGSize(width: width, height: height)
    }

    // MARK: Actions
    func buttonColorForButton(title : String!) -> UIColor
    {
        if title == nil {
            return scientificButtonColor
        }
        switch title {
        case "C": return clearButtonColor
        case "=","Register": return equalButtonColor
        case "1/x": return scientificButtonColor
        case "0"..."9",".","±": return operandButtonColor
        case "+","-","÷","✕": return operatorButtonColor
        default: return scientificButtonColor
        }
    }

    func buttonHighlightColorForButton(title : String!) -> UIColor
    {
        var hue = CGFloat(0.0), sat = CGFloat(0.0), value = CGFloat(0.0), alpha = CGFloat(0.0)
        let color = buttonColorForButton(title)
        color.getHue(&hue, saturation: &sat, brightness: &value, alpha: &alpha)
        return UIColor(hue: hue, saturation: sat, brightness: min(value*1.4, 1.0), alpha: 1.0)
    }

    @IBAction func buttonTouched(sender: CalulatorGradientButton) {
        sender.backgroundColor = buttonHighlightColorForButton(sender.titleLabel?.text)
    }

    @IBAction func buttonTouchCancel(sender: CalulatorGradientButton) {
        sender.backgroundColor = buttonColorForButton(sender.titleLabel?.text)
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if let button = sender.titleLabel?.text {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                println("selected \(button)")
                UIView.animateWithDuration(0.0625, animations: { () -> Void in
                    sender.backgroundColor = self.buttonColorForButton(sender.titleLabel?.text)
                })
            })

            if button == "Register" {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.displayHeight = (self.displayHeight == self.displayOpenHeight) ? self.displayClosedHeight : self.displayOpenHeight
                    self.registerTable?.alpha = (self.displayHeight == self.displayOpenHeight) ? 0.0 : 1.0
                    var bounds = self.displayHeader.frame
                    bounds.size.height = self.displayHeight
                    self.displayHeader.frame = bounds
                    self.view.setNeedsUpdateConstraints()
                }, completion: { (success) -> Void in
                    self.view.setNeedsUpdateConstraints()
                    self.collectionView?.reloadData()
                    self.registerTable?.reloadData()
                })
            } else {
                engine.handleButton(button)
                let name : CFStringRef! = "button"
                CFNotificationCenterPostNotification(darwinNotificationCenter, name, nil, nil, Boolean(1))
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    self.sharedDefaults?.setDouble(self.engine.value, forKey: "value")
                    self.sharedDefaults?.synchronize()
                })
            }
        }
    }

    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(self.view)
        //println("pan action: \(point) state \(sender.state.rawValue)")
        switch sender.state {
        case .Changed:
            if point.y > -10 {
                displayHeight = displayClosedHeight + max(0, min(displayOpenHeight - displayClosedHeight, point.y))
                self.registerTable?.alpha = displayHeight / displayOpenHeight
                self.view.setNeedsUpdateConstraints()
                self.collectionView?.reloadData()
                self.registerTable?.reloadData()
            }
        case .Ended:
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                if point.y > (self.displayOpenHeight - self.displayClosedHeight)/2 {
                    self.displayHeight = self.displayOpenHeight
                    self.registerTable?.alpha = 1.0
                } else {
                    self.displayHeight = self.displayClosedHeight
                    self.registerTable?.alpha = 0.0
                }
                self.view.setNeedsUpdateConstraints()
                self.collectionView?.reloadData()
                self.registerTable?.reloadData()
            })
        default:
            break
        }
    }

    func resetToValue(value : Double) {
        engine.resetToValue(value)
        valueLabel?.text = engine.operand
    }

    func valueChanged(newValue: Double) {
        valueLabel?.text = engine.operand
    }

    func memoryChanged(newValue: Double) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.sharedDefaults?.setDouble(newValue, forKey: "memory")
            self.sharedDefaults?.synchronize()
        })
    }
}

