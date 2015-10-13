//
//  ViewController.swift
//  PCLAlertController
//
//  Created by yoshida hiroyuki on 2015/10/12.
//  Copyright © 2015年 yoshida hiroyuki. All rights reserved.
//

import UIKit
import PCLBlurEffectAlert

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView! {
        didSet {
            // tableView
            tableView.estimatedRowHeight = 60
            tableView.rowHeight = 60
            tableView.layoutMargins = UIEdgeInsetsZero
            tableView.separatorInset = UIEdgeInsetsZero
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView.backgroundColor = UIColor(white: 1, alpha: 0.3)
            tableView.scrollIndicatorInsets.top = 64
            tableView.contentInset.top = 64
        }
    }

    var samples = ["sample1", "sample2", "sample3", "sample4", "sample5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
    }
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Alert"
        }
        return "ActionSheet"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell.textLabel?.text = samples[indexPath.row]
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var alertController: PCLBlurEffectAlert.Controller?
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: nil,
                    style: .Alert)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "yes",
                    style: .Destructive,
                    handler: { action in
                        print("yes")
                })
                alertController?.addAction(action1)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel",
                    style: .Cancel,
                    handler: nil)
                alertController?.addAction(cancelAction)
            } else if indexPath.row == 1 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: "message message message message message",
                    style: .AlertVertical)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1",
                    style: .Default,
                    handler: { action in
                        print("No.1")
                })
                alertController?.addAction(action1)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3",
                    style: .Destructive,
                    handler: { action in
                        print("No.2")
                })
                alertController?.configure(alertViewWidth: UIScreen.mainScreen().bounds.width - 100)
                alertController?.configure(backgroundColor: UIColor(red: 255, green: 100, blue: 255, alpha: 1))
                alertController?.configure(overlayBackgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5))
                alertController?.addAction(cancelAction)
                alertController?.configure(cornerRadius: 20)
                alertController?.margin = 20
            } else if indexPath.row == 2 {
                alertController = PCLBlurEffectAlert.Controller(title: nil,
                    message: nil,
                    style: .Alert)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1",
                    style: .Default,
                    handler: { action in
                        print("No.1")
                })
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2",
                    style: .Destructive,
                    handler: { action in
                        print("No.2")
                })
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel",
                    style: .Cancel,
                    handler: { action in
                        print("No.3")
                })
                alertController?.configure(cornerRadius: 0)
                alertController?.configure(overlayBackgroundColor: UIColor(red: 255, green: 0, blue: 255, alpha: 0.3))
                alertController?.configure(buttonFont: [.Cancel: UIFont.systemFontOfSize(30)],
                    buttonTextColor: [.Cancel: UIColor.redColor()],
                    buttonDisableTextColor: [.Cancel: UIColor.redColor()])
                alertController?.addAction(cancelAction)
            } else if indexPath.row == 3 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: "message message message message message",
                    style: .AlertVertical)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1",
                    style: .Default,
                    handler: { action in
                        print("No.1")
                })
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2",
                    style: .Default,
                    handler: { action in
                        print("No.2")
                })
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3",
                    style: .Destructive,
                    handler: { action in
                        print("No.3")
                })
                cancelAction.enabled = false
                alertController?.configure(backgroundColor: UIColor.whiteColor())
                alertController?.addTextFieldWithConfigurationHandler()
                alertController?.addTextFieldWithConfigurationHandler()
                alertController?.addAction(cancelAction)
                alertController?.configure(titleFont: UIFont.systemFontOfSize(14), textColor: UIColor.redColor())
                alertController?.configure(messageFont: UIFont.boldSystemFontOfSize(24), textColor: UIColor.blueColor())
                alertController?.configure(buttonDisableTextColor: [.Destructive: UIColor.redColor()])
            } else if indexPath.row == 4 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: "message message message message message",
                    effect: UIBlurEffect(style: .Dark),
                    style: .AlertVertical)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1",
                    style: .Default,
                    handler: { action in
                        print("No.1")
                })
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2",
                    style: .Default,
                    handler: { action in
                        print("No.2")
                })
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3",
                    style: .Destructive,
                    handler: { action in
                        print("No.3")
                })
                alertController?.configure(overlayBackgroundColor: UIColor(red: 0, green: 255, blue: 255, alpha: 0.3))
                alertController?.configure(backgroundColor: UIColor.clearColor())
                alertController?.addAction(cancelAction)
            } else {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: "message message message message message message message message message message",
                    style: .Alert)
                let yesAction = PCLBlurEffectAlert.AlertAction(title: "OK",
                    style: .Destructive,
                    handler: { action in
                        print("OK")
                })
                alertController?.addAction(yesAction)
            }
        } else {
            if indexPath.row == 0 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: nil,
                    style: .ActionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "yes",
                    style: .Destructive,
                    handler: { action in
                        print("yes")
                })
                alertController?.addAction(action1)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel",
                    style: .Cancel,
                    handler: nil)
                alertController?.addAction(cancelAction)
            } else if indexPath.row == 1 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: "message message message message message",
                    style: .ActionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1",
                    style: .Default,
                    handler: { action in
                        print("No.1")
                })
                alertController?.addAction(action1)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3",
                    style: .Destructive,
                    handler: { action in
                        print("No.2")
                })
                alertController?.configure(alertViewWidth: UIScreen.mainScreen().bounds.width - 100)
                alertController?.configure(backgroundColor: UIColor(red: 255, green: 100, blue: 255, alpha: 1))
                alertController?.addAction(cancelAction)
                alertController?.configure(cornerRadius: 20)
            } else if indexPath.row == 2 {
                alertController = PCLBlurEffectAlert.Controller(title: nil, message: nil, style: .ActionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1",
                    style: .Default,
                    handler: { action in
                        print("No.1")
                })
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2",
                    style: .Destructive,
                    handler: { action in
                        print("No.2")
                })
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel",
                    style: .Cancel,
                    handler: { action in
                        print("No.3")
                })
                alertController?.configure(cornerRadius: 0)
                alertController?.configure(buttonFont: [.Cancel: UIFont.systemFontOfSize(30)],
                    buttonTextColor: [.Cancel: UIColor.redColor()],
                    buttonDisableTextColor: [.Cancel: UIColor.redColor()])
                alertController?.addAction(cancelAction)
                alertController?.configure(buttonHeight: 80)
            } else if indexPath.row == 3 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: "message message message message message",
                    style: .ActionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1",
                    style: .Default,
                    handler: { action in
                        print("No.1")
                })
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2",
                    style: .Destructive,
                    handler: { action in
                        print("No.2")
                })
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel",
                    style: .Cancel,
                    handler: { action in
                        print("No.3")
                })
                alertController?.configure(backgroundColor: UIColor.whiteColor())
                alertController?.addAction(cancelAction)
                alertController?.configure(titleFont: UIFont.systemFontOfSize(14), textColor: UIColor.redColor())
                alertController?.configure(messageFont: UIFont.boldSystemFontOfSize(24), textColor: UIColor.blueColor())
            } else if indexPath.row == 4 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: "message message message message message",
                    effect: UIBlurEffect(style: .Dark),
                    style: .ActionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1",
                    style: .Default,
                    handler: { action in
                        print("No.1")
                })
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2",
                    style: .Default,
                    handler: { action in
                        print("No.2")
                })
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3",
                    style: .Destructive,
                    handler: { action in
                        print("No.3")
                })
                alertController?.configure(overlayBackgroundColor: UIColor(red: 255, green: 255, blue: 0, alpha: 0.3))
                alertController?.configure(backgroundColor: UIColor.clearColor())
                alertController?.addAction(cancelAction)
            } else {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                    message: "message message message message message message message message message message",
                    style: .ActionSheet)
                let yesAction = PCLBlurEffectAlert.AlertAction(title: "OK",
                    style: .Destructive,
                    handler: { action in
                        print("OK")
                })
                alertController?.configure(overlayBackgroundColor: UIColor(white: 1, alpha: 0.3))
                alertController?.configure(backgroundColor: UIColor.whiteColor())
                alertController?.addAction(yesAction)
            }
        }
        
        if let alertController = alertController {
            presentViewController(alertController, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
}












