//
//  MainViewController.swift
//  PCLAlertController
//
//  Created by yoshida hiroyuki on 2015/10/12.
//  Copyright © 2015年 yoshida hiroyuki. All rights reserved.
//

import UIKit
import PCLBlurEffectAlert

final class MainViewController: UIViewController {
    enum SampleRow: Int, CustomStringConvertible {
        case oneButton = 0
        case okCancel
        case titleMessage
        case buttonOnly
        case colorful
        case textField
        case image
        static var count: Int { return 7 }
        var description: String {
            switch self {
            case .oneButton: return "One button"
            case .okCancel: return "OK / Cancel"
            case .titleMessage: return "Has title and message"
            case .buttonOnly: return "Button only"
            case .colorful: return "Colorful"
            case .textField: return "Has textFiled"
            case .image: return "Has image"
            }
        }
    }
    enum Segmented: Int {
        case a = 0, b, c
        var style: PCLBlurEffectAlert.ControllerStyle {
            switch self {
            case .a: return .alert
            case .b: return .alertVertical
            case .c: return .actionSheet
            }
        }
        var effect: UIBlurEffect {
            switch self {
            case .a: return UIBlurEffect(style: .extraLight)
            case .b: return UIBlurEffect(style: .light)
            case .c: return UIBlurEffect(style: .dark)
            }
        }
    }
    @IBOutlet weak var styleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var blurEffecrSegmentedControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView! {
        didSet {
            // tableView
            tableView.estimatedRowHeight = 100
            tableView.layoutMargins = .zero
            tableView.separatorInset = .zero
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }
    }
    fileprivate var textField1: UITextField? {
        didSet {
            textField1?.addTarget(self, action: #selector(MainViewController.textFieldEditingChanged(_:)), for: UIControlEvents.editingChanged)
        }
    }
    fileprivate var textField2: UITextField? {
        didSet {
            textField2?.addTarget(self, action: #selector(MainViewController.textFieldEditingChanged(_:)), for: UIControlEvents.editingChanged)
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SampleRow.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        let row = SampleRow(rawValue: indexPath.row)
        cell.textLabel?.text = row?.description
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let style = Segmented(rawValue: styleSegmentedControl.selectedSegmentIndex)?.style,
            let effectStyle = Segmented(rawValue: blurEffecrSegmentedControl.selectedSegmentIndex),
            let row = SampleRow(rawValue: indexPath.row) else { return }
        let effect = effectStyle.effect
        switch row {
        case .oneButton:
            let alertController = PCLBlurEffectAlertController(title: row.description,
                                                               message: nil,
                                                               effect: effect,
                                                               style: style)
            let action = PCLBlurEffectAlertAction(title: "OK!", style: .default) { _ in
                print("You pressed OK!")
            }
            alertController.addAction(action)
            alertController.show()
        case .okCancel:
            let alertController = PCLBlurEffectAlertController(title: row.description,
                                                               message: nil,
                                                               effect: effect,
                                                               style: style)
            let action1 = PCLBlurEffectAlertAction(title: "OK!", style: .default) { _ in
                print("You pressed OK!")
            }
            let cancelAction = PCLBlurEffectAlertAction(title: "Cancel", style: .cancel) { _ in
                print("You pressed Cancel")
            }
            alertController.configure(alertViewWidth: 200)
            alertController.configure(cornerRadius: 0)
            alertController.addAction(action1)
            alertController.addAction(cancelAction)
            alertController.show()
        case .titleMessage:
            let alertController = PCLBlurEffectAlertController(title: "How are you doing?",
                                                               message: "Press a button!",
                                                               effect: effect,
                                                               style: style)
            switch effectStyle {
            case .c:
                alertController.configure(titleColor: .white)
                alertController.configure(messageColor: .white)
            default:
                break
            }
            let action1 = PCLBlurEffectAlertAction(title: "I’m fine.", style: .default) { _ in
                print("You pressed I’m fine.")
            }
            let action2 = PCLBlurEffectAlertAction(title: "Not so good.", style: .default) { _ in
                print("You pressed Not so good.")
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.show()
        case .buttonOnly:
            let alertController = PCLBlurEffectAlertController(title: nil,
                                                               message: nil,
                                                               effect: effect,
                                                               style: style)
            let action1 = PCLBlurEffectAlertAction(title: "Default", style: .default) { _ in
                print("You pressed Default")
            }
            let action2 = PCLBlurEffectAlertAction(title: "Destructive", style: .destructive) { _ in
                print("You pressed Destructive")
            }
            let cancelAction = PCLBlurEffectAlertAction(title: "Cancel", style: .cancel) { _ in
                print("You pressed Cancel")
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(cancelAction)
            alertController.show()
        case .colorful:
            let alertController = PCLBlurEffectAlertController(title: "title title title\ntitle title title title",
                                                               message: "message message message\n message message",
                                                               effect: effect,
                                                               style: style)
            alertController.configure(overlayBackgroundColor: UIColor.orange)
            alertController.configure(titleFont: UIFont.systemFont(ofSize: 24),
                                      titleColor: .red)
            alertController.configure(messageColor: .blue)
            alertController.configure(buttonFont: [.default: UIFont.systemFont(ofSize: 24),
                                                   .destructive: UIFont.boldSystemFont(ofSize: 20),
                                                   .cancel: UIFont.systemFont(ofSize: 14)],
                                      buttonTextColor: [.default: .brown,
                                                        .destructive: .blue,
                                                        .cancel: .gray])
            let action1 = PCLBlurEffectAlertAction(title: "Default", style: .default) { _ in
                print("You pressed No.1")
            }
            let action2 = PCLBlurEffectAlertAction(title: "Destructive", style: .destructive) { _ in
                print("You pressed No.2")
            }
            let cancelAction = PCLBlurEffectAlertAction(title: "Cancel", style: .cancel) { _ in
                print("You pressed Cancel")
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(cancelAction)
            alertController.show()
        case .textField:
            let alertController = PCLBlurEffectAlertController(title: "title title title title title title title",
                                                               message: "message message message message message",
                                                               effect: effect,
                                                               style: style)
            alertController.addTextField { textField in
                self.textField1 = textField
            }
            alertController.addTextField { textField in
                self.textField2 = textField
            }
            alertController.configure(textFieldsViewBackgroundColor: UIColor.white.withAlphaComponent(0.1))
            alertController.configure(textFieldBorderColor: .black)
            alertController.configure(buttonDisableTextColor: [.default: .lightGray, .destructive: .lightGray])
            let action1 = PCLBlurEffectAlertAction(title: "Default", style: .default) { _ in
                print("You pressed Default")
            }
            let action2 = PCLBlurEffectAlertAction(title: "Destructive", style: .destructive) { _ in
                print("You pressed Destructive")
            }
            let cancelAction = PCLBlurEffectAlertAction(title: "Cancel", style: .cancel) { _ in
                print("You pressed Cancel")
            }
            action1.isEnabled = false
            action2.isEnabled = false
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(cancelAction)
            alertController.show()
        case .image:
            let alertController = PCLBlurEffectAlertController(title: "title title title title title title title",
                                                               message: "message message message message message",
                                                               effect: effect,
                                                               style: style)
            alertController.addImageView(with: Assets.image.sample2)
            switch effectStyle {
            case .c:
                alertController.configure(titleColor: .white)
                alertController.configure(messageColor: .white)
            default:
                break
            }
            let catAction = PCLBlurEffectAlertAction(title: "Cat?", style: .default) { _ in
                print("You pressed Cat?")
            }
            let dogAction = PCLBlurEffectAlertAction(title: "Dog?", style: .default) { _ in
                print("You pressed Dog?")
            }
            alertController.addAction(catAction)
            alertController.addAction(dogAction)
            alertController.show()
        }
    }
}

// MARK: - UITextFieldDelegate
extension MainViewController {
    func textFieldEditingChanged(_ textField: UITextField) {
        guard let alertController = presentedViewController as? PCLBlurEffectAlertController else {
            return
        }
        alertController.actions.filter { $0.style != .cancel }.forEach {
            $0.isEnabled = textField1?.text?.isEmpty == false && textField2?.text?.isEmpty == false
        }
    }
}
