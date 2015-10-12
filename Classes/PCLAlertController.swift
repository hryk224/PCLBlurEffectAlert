//
//  PCLAlertController.swift
//  PCLAlertController
//
//  Created by yoshida hiroyuki on 2015/10/12.
//  Copyright © 2015年 yoshida hiroyuki. All rights reserved.
//

import UIKit

public enum PCLAlertControllerStyle : Int {
    case ActionSheet = 0, Alert, AlertVertical
}

public class PCLAlertController: UIViewController {

    private typealias Me = PCLAlertController
    
    private var message: String?
    private var textField: UITextField?
    
    private var style: PCLAlertControllerStyle = .ActionSheet
    
    var isActionSheet: Bool {
        return style == .ActionSheet
    }
    var isAlert: Bool {
        return style == .Alert
    }
    var isAlertVertical: Bool {
        return style == .AlertVertical
    }
    
    // OverlayView
    private(set) var overlayView = UIView()
    private var tapGestureRecognizer = UITapGestureRecognizer()
    
    // containerView
    private(set) var containerView = UIView()
    private var containerViewBottomLayoutConstraint: NSLayoutConstraint!
    
    // AlertView
    private(set) var alertView = UIView()
    
    // TextContainer
    private(set) var textAreaView = UIView()
    private var textAreaHeight: CGFloat = 0
    private var textAreaViewHeightLayoutConstraint: NSLayoutConstraint!
    private var textAreaVisualEffectView: UIVisualEffectView {
        return UIVisualEffectView(effect: effect) as UIVisualEffectView
    }
    private var textAreaVisualEffectViewHeightLayoutConstraint: NSLayoutConstraint!
    private var textFieldView = UIView()
    private var buttonAreaHeight: CGFloat = 0
    
    var actions = [PCLAlertAction]()
    var actionViews = [PCLAlertActionView]()
    
    // Font
    var titleFont = UIFont.boldSystemFontOfSize(16)
    var titleColor = UIColor.blueColor()
    
    var messageFont = UIFont.systemFontOfSize(14)
    var messageColor = UIColor.blackColor()
    
    // Color
    var overlayViewBackgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.3)
    var alertBackgroundColor = UIColor(white: 1, alpha: 0.6)
    var effect: UIBlurEffect = UIBlurEffect(style: .Light)
    
    // Size
    var contentWidth: CGFloat = 270
    var textAreaMargin: CGFloat = 8
    var textFieldHeight: CGFloat = 32
    var textFieldColor = UIColor(white: 1, alpha: 0.15)
    var borderWidth: CGFloat = 0.5
    var cornerRadius: CGFloat = 4
    
    // Status
    private var layoutFlg = false
    private var keyboardHeight: CGFloat = 0

    private var hasTitle: Bool {
        return title?.isEmpty == false
    }
    private var hasMessage: Bool {
        return message?.isEmpty == false
    }
    private var hasTextField: Bool {
        if let _ = textField {
            return true
        }
        return false
    }
    
    public convenience init(title: String, message: String, configurationHandler: ((UITextField!) -> Void)? = nil, style: PCLAlertControllerStyle) {
        self.init(nibName: nil, bundle: nil)        
        self.title = title
        self.message = message
        self.style = style
        configure()
    }
    
    func configure() {
        // NotificationCenter
        PCLNotificationManager.sharedManager().addAlertActionEnabledDidChangeNotificationObserver(self)
        PCLNotificationManager.sharedManager().addKeyboardNotificationObserver(self)
        
        // 背景見えるように
        modalPresentationStyle = .OverCurrentContext
        transitioningDelegate = self
        
        view.frame.size = UIScreen.mainScreen().bounds.size

        // OverlayView
        overlayView.frame = view.frame
        overlayView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleWidth]
        view.addSubview(overlayView)
        
        if isActionSheet {
            tapGestureRecognizer.addTarget(self, action: "handleTap:")
            overlayView.addGestureRecognizer(tapGestureRecognizer)
        } else {
            tapGestureRecognizer.addTarget(self, action: "handleTap:")
            overlayView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        textAreaVisualEffectView.userInteractionEnabled = false
        alertView.addSubview(textAreaVisualEffectView)
        textAreaView.userInteractionEnabled = false
        alertView.addSubview(textAreaView)
        containerView.addSubview(alertView)
        containerView.userInteractionEnabled = false
        view.addSubview(containerView)
        
        configUI()
        prepareConstraints()
        setConstraints()
    }
    
    private func configUI() {
        if isActionSheet {
            
        }
    }
    
    private func prepareConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false
        textAreaView.translatesAutoresizingMaskIntoConstraints = false
        textAreaVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setConstraints() {
        // containerView
        let containerViewTopConstraint = NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let containerViewRightConstraint = NSLayoutConstraint(item: containerView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        let containerViewLeftConstraint = NSLayoutConstraint(item: containerView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        containerViewBottomLayoutConstraint = NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraints([containerViewTopConstraint, containerViewRightConstraint, containerViewLeftConstraint, containerViewBottomLayoutConstraint])
    }
    
    func addTextField(configurationHandler: ((UITextField!) -> Void)?) {
        if isActionSheet {
            return
        }
        if let _ = textField {
            return
        }
        textField = PCLTextField()
        (textField as? PCLTextField)?.leftMargin = 8
        textField?.frame.size = CGSizeMake(contentWidth, textFieldHeight)
        textField?.borderStyle = .None
        textField?.backgroundColor = textFieldColor
        configurationHandler?(textField)
        textFieldView.addSubview(textField!)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        overlayView.backgroundColor = overlayViewBackgroundColor
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        adjustLayout()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        PCLNotificationManager.sharedManager().removeAlertActionEnabledDidChangeNotificationObserver(self)
        PCLNotificationManager.sharedManager().removeKeyboardNotificationObserver(self)
    }
    
    // Attaches an action object to the alert or action sheet.
    public func addAction(action: PCLAlertAction) {
        // Add Action
        actions.append(action)
        // Add Butto
        let actionView = PCLAlertActionView(action: action, effect: effect)
        actionView.button.addTarget(
            self,
            action: Selector("buttonWasTouchUpInside:"),
            forControlEvents: .TouchUpInside)
        actionView.tag = actionViews.count + 1
        actionViews.append(actionView)        
    }

}

// MARK: - private
private extension PCLAlertController {
    
    private func adjustLayout() {
        
        if layoutFlg {
            return
        }
        
        layoutFlg = true
        
        overlayView.backgroundColor = overlayViewBackgroundColor
        textAreaView.backgroundColor = alertBackgroundColor
        
        var textAreaPositionY: CGFloat = textAreaMargin * 2
        let textAreaWidth = contentWidth - (textAreaMargin * 4)
        
        if hasTitle {
            let titleLabel = UILabel()
            titleLabel.frame.size = CGSizeMake(textAreaWidth, 0)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .Center
            titleLabel.font = titleFont
            titleLabel.textColor = titleColor
            titleLabel.text = title
            titleLabel.sizeToFit()
            titleLabel.frame = CGRectMake(textAreaMargin * 2, textAreaPositionY, textAreaWidth, titleLabel.frame.height)
            textAreaView.addSubview(titleLabel)
            textAreaPositionY += titleLabel.frame.height
        }
        
        if hasMessage {
            textAreaPositionY += hasTitle ? (textAreaMargin / 2) : 0
            let messageLabel = UILabel()
            messageLabel.frame.size = CGSizeMake(textAreaWidth, 0)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .Center
            messageLabel.text = message
            messageLabel.font = messageFont
            messageLabel.textColor = messageColor
            messageLabel.sizeToFit()
            messageLabel.frame = CGRectMake(textAreaMargin * 2, textAreaPositionY, textAreaWidth, messageLabel.frame.height)
            textAreaView.addSubview(messageLabel)
            textAreaPositionY += messageLabel.frame.height
        }
        
        // TextFieldContainerView
        if hasTextField {
            if let textField = textField {
                if (hasTitle || hasMessage) {
                    textAreaPositionY += textAreaMargin
                }
                textFieldView.backgroundColor = UIColor.clearColor()
                textFieldView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).CGColor
                textFieldView.layer.borderWidth = borderWidth
                textFieldView.layer.masksToBounds = true
                textFieldView.clipsToBounds = true
                textFieldView.layer.cornerRadius = cornerRadius
                textAreaView.addSubview(textFieldView)
                
                var textFieldViewHeight: CGFloat = 0
                
                textField.frame = CGRectMake(0, textFieldViewHeight, textAreaWidth, textField.frame.height)
                textFieldViewHeight += textField.frame.height + borderWidth
                textFieldViewHeight -= borderWidth
                textFieldView.frame = CGRectMake(textAreaMargin * 2, textAreaPositionY, textAreaWidth, textFieldViewHeight)
                textAreaPositionY += textFieldViewHeight
            }
        }
        
        if hasTitle || hasMessage || hasTextField {
            textAreaPositionY += (textAreaMargin * 2)
        } else {
            textAreaPositionY = 0
        }
        
        textAreaHeight = textAreaPositionY
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private func reloadAlertViewHeight() {
        
    }

    
    
    dynamic func handleTap(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

// MARK: - UIViewControllerTransitioningDelegate
extension PCLAlertController: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PCLAlertTransitionAnimator(present: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PCLAlertTransitionAnimator(present: false)
    }
    
}

// MARK: - AlertActionEnabledDidChangeNotificationObserver
extension PCLAlertController: AlertActionEnabledDidChangeNotificationObserver {
    
    func didAlertActionEnabledDidChange(notification: NSNotification) {
        for index in 0..<actionViews.count {
            actionViews[index].button.enabled = actions[index].enabled
        }
    }
    
}

// MARK: - KeyboardNotificationObserver
extension PCLAlertController: KeyboardNotificationObserver {
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String: NSValue] {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue().size
            keyboardHeight = keyboardSize.height
            reloadAlertViewHeight()
            containerViewBottomLayoutConstraint.constant = -keyboardHeight
            UIView.animateWithDuration(0.3,
                animations: {
                    self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
        reloadAlertViewHeight()
        containerViewBottomLayoutConstraint.constant = keyboardHeight
        UIView.animateWithDuration(0.3,
            animations: {
                self.view.layoutIfNeeded()
        })
    }
    
}


class PCLTextField: UITextField {
    
    var leftMargin: CGFloat = 0
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var inset = bounds
        inset.origin.x += leftMargin
        inset.size.width -= leftMargin
        return inset
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var inset = bounds
        inset.origin.x += leftMargin
        inset.size.width -= leftMargin
        return inset
    }
    
}
