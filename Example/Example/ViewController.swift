//
//  ViewController.swift
//  PCLAlertController
//
//  Created by yoshida hiroyuki on 2015/10/12.
//  Copyright © 2015年 yoshida hiroyuki. All rights reserved.
//

import UIKit
import PCLAlertController

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
        }
    }

}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell.textLabel?.text = "あああああああ"
        if indexPath.row == 3 {
            cell.backgroundColor = UIColor.redColor()
        }
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertController = PCLAlertController(title: "あああああああああ", message: "いいいいいいいいい", style: .Alert)
        let action = PCLAlertAction(title: "あああ", style: PCLAlertActionStyle.Default) { (action) -> Void in
            print("あああ")
        }
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
}












