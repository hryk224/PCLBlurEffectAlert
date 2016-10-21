//
//  PCLBlurEffectAlert.swift
//  Pods
//
//  Created by hryk224 on 2015/10/14.
//
//

import UIKit

typealias Alert = PCLBlurEffectAlert

open class PCLBlurEffectAlert {
    public enum ActionStyle : Int {
        case `default` = 0, cancel, destructive
        var isCancel: Bool {
            return self == .cancel
        }
    }
    public enum ControllerStyle : Int {
        case actionSheet = 0, alert, alertVertical
    }
}

// MARK: - RespondsView
extension PCLBlurEffectAlert {
    final class RespondsView: UIView {
        weak var delegate: PCLRespondsViewDelegate?
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            delegate?.respondsViewDidTouch(self)
        }
    }
}

// MARK: - PCLRespondsViewDelegate
protocol PCLRespondsViewDelegate: class {
    func respondsViewDidTouch(_ view: UIView)
}

// MARK: - NotificationManager
extension PCLBlurEffectAlert {
    struct NotificationManager {
        typealias Manager = Alert.NotificationManager
        static let shared = Alert.NotificationManager()
        fileprivate let notificationCenter = NotificationCenter.default
    }
}

// MARK: - keyboardWillShow/Hide
@objc protocol PCLAlertKeyboardNotificationObserver: class {
    func keyboardWillShow(_ notification: Notification)
    func keyboardWillHide(_ notification: Notification)
}

extension PCLBlurEffectAlert.NotificationManager {
    func addKeyboardNotificationObserver(_ observer: PCLAlertKeyboardNotificationObserver) {
        notificationCenter.addObserver(observer, selector: #selector(PCLAlertKeyboardNotificationObserver.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(observer, selector: #selector(PCLAlertKeyboardNotificationObserver.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func removeKeyboardNotificationObserver(_ observer: PCLAlertKeyboardNotificationObserver) {
        notificationCenter.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func postKeyboardWillShowNotification() {
        notificationCenter.post(Notification(name: NSNotification.Name.UIKeyboardWillShow, object: nil))
    }
    func postKeyboardWillHideNotification() {
        notificationCenter.post(Notification(name: NSNotification.Name.UIKeyboardWillHide, object: nil))
    }
}


// MARK: - AlertActionEnabledDidChange
@objc protocol PCLAlertActionEnabledDidChangeNotificationObserver: class {
    func didAlertActionEnabledDidChange(_ notification: Notification)
}
// MARK: - private
extension PCLBlurEffectAlert.NotificationManager {
    private static let DidAlertActionEnabledDidChangeNotification = "DidAlertActionEnabledDidChangeNotification"
    func addAlertActionEnabledDidChangeNotificationObserver(_ observer: PCLAlertActionEnabledDidChangeNotificationObserver) {
        notificationCenter.addObserver(observer, selector: #selector(PCLAlertActionEnabledDidChangeNotificationObserver.didAlertActionEnabledDidChange(_:)), name: NSNotification.Name(rawValue: Manager.DidAlertActionEnabledDidChangeNotification) , object: nil)
    }
    func removeAlertActionEnabledDidChangeNotificationObserver(_ observer: PCLAlertActionEnabledDidChangeNotificationObserver) {
        notificationCenter.removeObserver(observer, name: NSNotification.Name(rawValue: Manager.DidAlertActionEnabledDidChangeNotification), object: nil)
    }
    func postAlertActionEnabledDidChangeNotification() {
        notificationCenter.post(Notification(name: Notification.Name(rawValue: Manager.DidAlertActionEnabledDidChangeNotification), object: nil, userInfo: nil))
    }
}
