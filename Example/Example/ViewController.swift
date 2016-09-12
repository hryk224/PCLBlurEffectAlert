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
            tableView.layoutMargins = UIEdgeInsets.zero
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Alert"
        }
        return "ActionSheet"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = samples[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var alertController: PCLBlurEffectAlert.Controller?
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: nil,
                                                                style: .alert)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "yes", style: .destructive) { action in
                    print("yes")
                }
                alertController?.addAction(action1)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel", style: .cancel, handler: nil)
                alertController?.addAction(cancelAction)
            } else if indexPath.row == 1 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: "message message message message message",
                                                                style: .alertVertical)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1", style: .default) { action in
                    print("No.1")
                }
                alertController?.addAction(action1)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3", style: .destructive) { action in
                    print("No.2")
                }
                alertController?.configure(alertViewWidth: UIScreen.main.bounds.width - 100)
                alertController?.configure(backgroundColor: UIColor(red: 255, green: 100, blue: 255, alpha: 1))
                alertController?.configure(overlayBackgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5))
                alertController?.addAction(cancelAction)
                alertController?.configure(cornerRadius: 20)
                alertController?.margin = 20
            } else if indexPath.row == 2 {
                alertController = PCLBlurEffectAlert.Controller(title: nil, message: nil, style: .alert)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1", style: .default) { action in
                    print("No.1")
                }
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2", style: .destructive) { action in
                    print("No.2")
                }
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel", style: .cancel) { action in
                    print("No.3")
                }
                alertController?.configure(cornerRadius: 0)
                alertController?.configure(overlayBackgroundColor: UIColor(red: 255, green: 0, blue: 255, alpha: 0.3))
                alertController?.configure(buttonFont: [.cancel: UIFont.systemFont(ofSize: 30)],
                                           buttonTextColor: [.cancel: UIColor.red],
                                           buttonDisableTextColor: [.cancel: UIColor.red])
                alertController?.addAction(cancelAction)
            } else if indexPath.row == 3 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: "message message message message message",
                                                                style: .alertVertical)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1", style: .default) { action in
                    print("No.1")
                }
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2", style: .default) { action in
                    print("No.2")
                }
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3", style: .destructive) { action in
                    print("No.3")
                }
                cancelAction.enabled = false
                alertController?.configure(backgroundColor: UIColor.white)
                alertController?.addTextFieldWithConfigurationHandler()
                alertController?.addTextFieldWithConfigurationHandler()
                alertController?.addAction(cancelAction)
                
                alertController?.configure(titleFont: UIFont.systemFont(ofSize: 14), textColor: UIColor.red)
                alertController?.configure(messageFont: UIFont.boldSystemFont(ofSize: 24), textColor: UIColor.blue)
                alertController?.configure(buttonDisableTextColor: [.destructive: UIColor.red])
            } else if indexPath.row == 4 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: "message message message message message",
                                                                effect: UIBlurEffect(style: .dark),
                                                                style: .alertVertical)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1", style: .default) { action in
                    print("No.1")
                }
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2", style: .default) { action in
                    print("No.2")
                }
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3", style: .destructive) { action in
                    print("No.3")
                }
                alertController?.configure(overlayBackgroundColor: UIColor(red: 0, green: 255, blue: 255, alpha: 0.3))
                alertController?.configure(backgroundColor: UIColor.clear)
                alertController?.addAction(cancelAction)
            } else {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: "message message message message message message message message message message",
                                                                style: .alert)
                let yesAction = PCLBlurEffectAlert.AlertAction(title: "OK", style: .destructive) { action in
                    print("OK")
                }
                alertController?.addAction(yesAction)
            }
        } else {
            if indexPath.row == 0 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: nil,
                                                                style: .actionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "yes", style: .destructive) { action in
                    print("yes")
                }
                alertController?.addAction(action1)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel", style: .cancel, handler: nil)
                alertController?.addAction(cancelAction)
            } else if indexPath.row == 1 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: "message message message message message",
                                                                style: .actionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1", style: .default) { action in
                    print("No.1")
                }
                alertController?.addAction(action1)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3", style: .destructive) { action in
                    print("No.2")
                }
                alertController?.configure(alertViewWidth: UIScreen.main.bounds.width - 100)
                alertController?.configure(backgroundColor: UIColor(red: 255, green: 100, blue: 255, alpha: 1))
                alertController?.addAction(cancelAction)
                alertController?.configure(cornerRadius: 20)
            } else if indexPath.row == 2 {
                alertController = PCLBlurEffectAlert.Controller(title: nil, message: nil, style: .actionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1", style: .default) { action in
                    print("No.1")
                }
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2", style: .destructive) { action in
                    print("No.2")
                }
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel", style: .cancel) { action in
                    print("No.3")
                }
                alertController?.configure(cornerRadius: 0)
                alertController?.configure(buttonFont: [.cancel: UIFont.systemFont(ofSize: 30)],
                                           buttonTextColor: [.cancel: UIColor.red],
                                           buttonDisableTextColor: [.cancel: UIColor.red])
                alertController?.addAction(cancelAction)
                alertController?.configure(buttonHeight: 80)
            } else if indexPath.row == 3 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: "message message message message message",
                                                                style: .actionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1", style: .default) { action in
                    print("No.1")
                }
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2", style: .destructive) { action in
                    print("No.2")
                }
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "cancel", style: .cancel) { action in
                    print("No.3")
                }
                alertController?.configure(backgroundColor: UIColor.white)
                alertController?.addAction(cancelAction)
                alertController?.configure(titleFont: UIFont.systemFont(ofSize: 14), textColor: UIColor.red)
                alertController?.configure(messageFont: UIFont.boldSystemFont(ofSize: 24), textColor: UIColor.blue)
            } else if indexPath.row == 4 {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: "message message message message message",
                                                                effect: UIBlurEffect(style: .dark),
                                                                style: .actionSheet)
                let action1 = PCLBlurEffectAlert.AlertAction(title: "No.1", style: .default) { action in
                    print("No.1")
                }
                alertController?.addAction(action1)
                let action2 = PCLBlurEffectAlert.AlertAction(title: "No.2", style: .default) { action in
                    print("No.2")
                }
                alertController?.addAction(action2)
                let cancelAction = PCLBlurEffectAlert.AlertAction(title: "No.3", style: .destructive) { action in
                    print("No.3")
                }
                alertController?.configure(overlayBackgroundColor: UIColor(red: 255, green: 255, blue: 0, alpha: 0.3))
                alertController?.configure(backgroundColor: UIColor.clear)
                alertController?.addAction(cancelAction)
            } else {
                alertController = PCLBlurEffectAlert.Controller(title: "title title title title title title title",
                                                                message: "message message message message message message message message message message",
                                                                style: .actionSheet)
                let yesAction = PCLBlurEffectAlert.AlertAction(title: "OK", style: .destructive) { action in
                    print("OK")
                }
                alertController?.configure(overlayBackgroundColor: UIColor(white: 1, alpha: 0.3))
                alertController?.configure(backgroundColor: UIColor.white)
                alertController?.addAction(yesAction)
            }
        }
        
        if let alertController = alertController {
            present(alertController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
