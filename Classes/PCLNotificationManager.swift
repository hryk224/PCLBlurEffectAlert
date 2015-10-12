//
//  PCLNotificationManager.swift
//  Pods
//
//  Created by yoshida hiroyuki on 2015/10/12.
//
//

import UIKit

class PCLNotificationManager {

    private typealias Manager = PCLNotificationManager
    private static let sharedInstance = PCLNotificationManager()
    
    class func sharedManager() -> PCLNotificationManager {
        return sharedInstance
    }
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
}

// MARK: Keyboard
protocol KeyboardNotificationObserver: class {
    func keyboardWillShow(notification: NSNotification)
    func keyboardWillHide(notification: NSNotification)
}

extension PCLNotificationManager {
    
    func addKeyboardNotificationObserver(observer: KeyboardNotificationObserver) {
        notificationCenter.addObserver(observer, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(observer, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotificationObserver(observer: KeyboardNotificationObserver) {
        notificationCenter.removeObserver(observer, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(observer, name: UIKeyboardWillHideNotification, object: nil)
    }
    func postKeyboardWillShowNotification() {
        notificationCenter.postNotification(NSNotification(name: UIKeyboardWillShowNotification, object: nil))
    }
    
    func postKeyboardWillHideNotification() {
        notificationCenter.postNotification(NSNotification(name: UIKeyboardWillHideNotification, object: nil))
    }
    
}

// MARK: - AlertActionEnabledDidChange
protocol AlertActionEnabledDidChangeNotificationObserver: class {
    func didAlertActionEnabledDidChange(notification: NSNotification)
}

extension PCLNotificationManager {
    
    static let DidAlertActionEnabledDidChangeNotification = "DidAlertActionEnabledDidChangeNotification"
    
    func addAlertActionEnabledDidChangeNotificationObserver(observer: AlertActionEnabledDidChangeNotificationObserver) {
        notificationCenter.addObserver(observer, selector: "didAlertActionEnabledDidChange:", name: Manager.DidAlertActionEnabledDidChangeNotification , object: nil)
    }
    
    func removeAlertActionEnabledDidChangeNotificationObserver(observer: AlertActionEnabledDidChangeNotificationObserver) {
        notificationCenter.removeObserver(observer, name: Manager.DidAlertActionEnabledDidChangeNotification, object: nil)
    }
    
    func postAlertActionEnabledDidChangeNotification() {
        notificationCenter.postNotification(NSNotification(name: Manager.DidAlertActionEnabledDidChangeNotification, object: nil, userInfo: nil))
    }
}