//
//  PCLBlurEffectAlert.swift
//  Pods
//
//  Created by hiroyuki yoshida on 2015/10/14.
//
//

import UIKit

public class PCLBlurEffectAlert {
    
    private typealias Alert = PCLBlurEffectAlert
    
    public enum ActionStyle : Int {
        case Default = 0, Cancel, Destructive
    }
    
    public class AlertAction {
        
        var tag: Int = -1
        var title: String?
        var style: Alert.ActionStyle
        var handler: ((Alert.AlertAction!) -> Void)?
        public var enabled: Bool = true {
            didSet {
                if (oldValue != enabled) {
                    Alert.NotificationManager.sharedInstance.postAlertActionEnabledDidChangeNotification()
                }
            }
        }
        
        var button: UIButton!
        var visualEffectView: UIVisualEffectView?
        var backgroundView = UIView()
        
        public init(title: String,
            style: Alert.ActionStyle,
            handler: ((Alert.AlertAction!) -> Void)?) {
                self.title = title
                self.style = style
                self.handler = handler
                self.button = UIButton(type: .Custom)
                self.button.tag = tag
                self.button.adjustsImageWhenHighlighted = false
                self.button.adjustsImageWhenDisabled = false
                self.button.layer.masksToBounds = true
                self.button.setTitle(title, forState: .Normal)
                self.button.titleLabel?.numberOfLines = 1
                self.button.titleLabel?.lineBreakMode = .ByTruncatingTail
                self.button.titleLabel?.textAlignment = .Center
        }
        
    }
    
    public enum ControllerStyle : Int {
        case ActionSheet = 0, Alert, AlertVertical
    }

    public class Controller: UIViewController, PCLRespondsViewDelegate {
        
        private typealias Controller = Alert.Controller
        
        private var isNeedlayout = true
        
        private var message: String?
        private var textField: UITextField?
        private var style: Alert.ControllerStyle = .ActionSheet
        private var effect: UIBlurEffect = UIBlurEffect(style: .ExtraLight)
        
        // actions
        private var actions = [AlertAction]()
        private var cancelAction: AlertAction?
        private var cancelActionTag: Int?
        private var keyboardHeight: CGFloat = 0
        
        // textFields
        private(set) var textFields: [UITextField] = [UITextField]()
        
        var isActionSheet: Bool {
            return style == .ActionSheet
        }
        var isAlert: Bool {
            return style == .Alert
        }
        var isAlertVertical: Bool {
            return style == .AlertVertical
        }
        
        private var hasTitle: Bool {
            return title?.isEmpty == false
        }
        
        private var hasMessage: Bool {
            return message?.isEmpty == false
        }
        
        private var hasTextField: Bool {
            return !textFields.isEmpty
        }
        
        // UI
        public var cornerRadius: CGFloat = 0
        public var thin: CGFloat = 0.5
        
        // OverlayView
        private var overlayView = UIView()
        private var tapGestureRecognizer = UITapGestureRecognizer()
        
        // ContainerView
        private var containerView = RespondsView()
        private var containerViewBottomLayoutConstraint: NSLayoutConstraint!
        
        // AlertView
        private var alertView = UIView()
        private var alertViewWidth: CGFloat = 0
        private var alertViewWidthConstraint: NSLayoutConstraint!
        private var alertViewHeightConstraint: NSLayoutConstraint!
        
        // CornerView
        private var cornerView = UIView()
        private var cornerViewHeightConstraint: NSLayoutConstraint!
        
        // textAreaView
        private var textAreaView = UIView()
        private var textAreaHeight: CGFloat = 0
        private var textAreaViewHeightConstraint: NSLayoutConstraint!
        private var textAreaVisualEffectView: UIVisualEffectView!
        private var textAreaVisualEffectViewHeightConstraint: NSLayoutConstraint!
        private var textAreaBackgroundView = UIView()
        private var textAreaBackgroundViewHeightConstraint: NSLayoutConstraint!
        
        // titleLabel
        private var titleLabel = UILabel()
        
        // messageLabel
        private var messageLabel = UILabel()
        
        // public
        public var margin: CGFloat = 8
        public var overlayBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        public var backgroundColor = UIColor(white: 1, alpha: 0.05)
        public var titleFont = UIFont.boldSystemFontOfSize(16)
        public var titleColor = UIColor.brownColor()
        public var messageFont = UIFont.systemFontOfSize(14)
        public var messageColor = UIColor.blackColor()
        public var buttonFont: [Alert.ActionStyle : UIFont!] = [
            .Default : UIFont.systemFontOfSize(16),
            .Cancel  : UIFont.systemFontOfSize(16),
            .Destructive  : UIFont.systemFontOfSize(16)
        ]
        public var buttonTextColor: [Alert.ActionStyle : UIColor] = [
            .Default : UIColor.blackColor(),
            .Cancel  : UIColor.grayColor(),
            .Destructive  : UIColor.redColor()
        ]
        public var buttonDisableTextColor: [Alert.ActionStyle : UIColor] = [
            .Default : UIColor.blackColor(),
            .Cancel  : UIColor.blackColor(),
            .Destructive  : UIColor.redColor()
        ]
        public var textFieldHeight: CGFloat = 32
        public var textFieldBorderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        public var buttonHeight: CGFloat = 44
        
        public convenience init(title: String?, message: String?, effect: UIBlurEffect = UIBlurEffect(style: .ExtraLight), style: Alert.ControllerStyle) {
            self.init(nibName: nil, bundle: nil)
            self.title = title
            self.message = message
            self.style = style
            self.effect = effect
            
            //
            self.textAreaVisualEffectView = UIVisualEffectView(effect: effect) as UIVisualEffectView

            // NotificationCenter
            Alert.NotificationManager.sharedInstance.addAlertActionEnabledDidChangeNotificationObserver(self)
            Alert.NotificationManager.sharedInstance.addKeyboardNotificationObserver(self)
            
            // 背景見えるように
            modalPresentationStyle = .OverCurrentContext
            transitioningDelegate = self
            view.frame.size = UIScreen.mainScreen().bounds.size
            overlayView.frame = UIScreen.mainScreen().bounds
            view.insertSubview(overlayView, atIndex: 0)
            view.addSubview(containerView)
            
            containerView.delegate = self
            containerView.addSubview(alertView)
            
            cornerView.addSubview(textAreaBackgroundView)
            cornerView.addSubview(textAreaVisualEffectView)
            cornerView.addSubview(textAreaView)
            
            alertView.addSubview(cornerView)
            
            if isActionSheet {
                configure(alertViewWidth: view.frame.width - margin * 2)
            } else {
                configure(alertViewWidth: 320 - (margin * 2))
            }
            configure(cornerRadius: 4)
            configureConstraints()
        }
        
        
        private func configureConstraints() {
            containerView.translatesAutoresizingMaskIntoConstraints = false
            let containerViewTopConstraint = NSLayoutConstraint(item: containerView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: view,
                attribute: .Top,
                multiplier: 1,
                constant: 0)
            let containerViewRightConstraint = NSLayoutConstraint(item: containerView,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: view,
                attribute: .Right,
                multiplier: 1,
                constant: 0)
            let containerViewLeftConstraint = NSLayoutConstraint(item: containerView,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: view,
                attribute: .Left,
                multiplier: 1,
                constant: 0)
            containerViewBottomLayoutConstraint = NSLayoutConstraint(item: containerView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: view,
                attribute: .Bottom,
                multiplier: 1,
                constant: 0)
            view.addConstraints([containerViewTopConstraint, containerViewRightConstraint, containerViewLeftConstraint, containerViewBottomLayoutConstraint])
            
            alertView.translatesAutoresizingMaskIntoConstraints = false
            
            if isActionSheet {
                let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView,
                    attribute: .CenterX,
                    relatedBy: .Equal,
                    toItem: containerView,
                    attribute: .CenterX,
                    multiplier: 1,
                    constant: 0)
                let alertViewBottomConstraint = NSLayoutConstraint(item: alertView,
                    attribute: .Bottom,
                    relatedBy: .Equal,
                    toItem: containerView,
                    attribute: .Bottom,
                    multiplier: 1,
                    constant: -(margin))
                alertViewWidthConstraint = NSLayoutConstraint(item: alertView,
                    attribute: .Width,
                    relatedBy: .Equal,
                    toItem: nil,
                    attribute: .Width,
                    multiplier: 1,
                    constant: alertViewWidth)
                alertViewHeightConstraint = NSLayoutConstraint(item: alertView,
                    attribute: .Height,
                    relatedBy: .Equal,
                    toItem: nil,
                    attribute: .Height,
                    multiplier: 1,
                    constant: 0)
                containerView.addConstraints([alertViewCenterXConstraint, alertViewBottomConstraint, alertViewWidthConstraint, alertViewHeightConstraint])
            } else {
                let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView,
                    attribute: .CenterX,
                    relatedBy: .Equal,
                    toItem: containerView,
                    attribute: .CenterX,
                    multiplier: 1,
                    constant: 0)
                let alertViewCenterYConstraint = NSLayoutConstraint(item: alertView,
                    attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: containerView,
                    attribute: .CenterY,
                    multiplier: 1,
                    constant: 0)
                alertViewWidthConstraint = NSLayoutConstraint(item: alertView,
                    attribute: .Width,
                    relatedBy: .Equal,
                    toItem: nil,
                    attribute: .Width,
                    multiplier: 1,
                    constant: alertViewWidth)
                alertViewHeightConstraint = NSLayoutConstraint(item: alertView,
                    attribute: .Height,
                    relatedBy: .Equal,
                    toItem: nil,
                    attribute: .Height,
                    multiplier: 1,
                    constant: 0)
                containerView.addConstraints([alertViewCenterXConstraint, alertViewCenterYConstraint, alertViewWidthConstraint, alertViewHeightConstraint])
            }
            
            cornerView.translatesAutoresizingMaskIntoConstraints = false
            
            if isActionSheet {
                let cornerViewTopConstraint = NSLayoutConstraint(item: cornerView,
                    attribute: .Top,
                    relatedBy: .Equal,
                    toItem: alertView,
                    attribute: .Top,
                    multiplier: 1,
                    constant: 0)
                let cornerViewRightConstraint = NSLayoutConstraint(item: cornerView,
                    attribute: .Right,
                    relatedBy: .Equal,
                    toItem: alertView,
                    attribute: .Right,
                    multiplier: 1,
                    constant: 0)
                let cornerViewLeftConstraint = NSLayoutConstraint(item: cornerView,
                    attribute: .Left,
                    relatedBy: .Equal,
                    toItem: alertView,
                    attribute: .Left,
                    multiplier: 1,
                    constant: 0)
                cornerViewHeightConstraint = NSLayoutConstraint(item: cornerView,
                    attribute: .Height,
                    relatedBy: .Equal,
                    toItem: nil,
                    attribute: .Height,
                    multiplier: 1,
                    constant: 0)
                alertView.addConstraints([cornerViewTopConstraint, cornerViewRightConstraint, cornerViewLeftConstraint, cornerViewHeightConstraint])
            } else {
                let cornerViewTopConstraint = NSLayoutConstraint(item: cornerView,
                    attribute: .Top,
                    relatedBy: .Equal,
                    toItem: alertView,
                    attribute: .Top,
                    multiplier: 1,
                    constant: 0)
                let cornerViewRightConstraint = NSLayoutConstraint(item: cornerView,
                    attribute: .Right,
                    relatedBy: .Equal,
                    toItem: alertView,
                    attribute: .Right,
                    multiplier: 1,
                    constant: 0)
                let cornerViewLeftConstraint = NSLayoutConstraint(item: cornerView,
                    attribute: .Left,
                    relatedBy: .Equal,
                    toItem: alertView,
                    attribute: .Left,
                    multiplier: 1,
                    constant: 0)
                let cornerViewBottomLayoutConstraint = NSLayoutConstraint(item: cornerView,
                    attribute: .Bottom,
                    relatedBy: .Equal,
                    toItem: alertView,
                    attribute: .Bottom,
                    multiplier: 1,
                    constant: 0)
                alertView.addConstraints([cornerViewTopConstraint, cornerViewRightConstraint, cornerViewLeftConstraint, cornerViewBottomLayoutConstraint])
            }
        
            textAreaView.translatesAutoresizingMaskIntoConstraints = false
            textAreaVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
            textAreaBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            let textAreaViewTopConstraint = NSLayoutConstraint(item: textAreaView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: cornerView,
                attribute: .Top,
                multiplier: 1,
                constant: 0)
            let textAreaViewRightConstraint = NSLayoutConstraint(item: textAreaView,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: cornerView,
                attribute: .Right,
                multiplier: 1,
                constant: 0)
            let textAreaViewLeftConstraint = NSLayoutConstraint(item: textAreaView,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: cornerView,
                attribute: .Left,
                multiplier: 1,
                constant: 0)
            textAreaViewHeightConstraint = NSLayoutConstraint(item: textAreaView,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .Height,
                multiplier: 1,
                constant: 0)
            
            cornerView.addConstraints([textAreaViewTopConstraint, textAreaViewRightConstraint, textAreaViewLeftConstraint, textAreaViewHeightConstraint])
            
            let textAreaVisualEffectViewTopConstraint = NSLayoutConstraint(item: textAreaVisualEffectView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: cornerView,
                attribute: .Top,
                multiplier: 1,
                constant: 0)
            let textAreaVisualEffectViewRightConstraint = NSLayoutConstraint(item: textAreaVisualEffectView,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: cornerView,
                attribute: .Right,
                multiplier: 1,
                constant: 0)
            let textAreaVisualEffectViewLeftConstraint = NSLayoutConstraint(item: textAreaVisualEffectView,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: cornerView,
                attribute: .Left,
                multiplier: 1,
                constant: 0)
            textAreaVisualEffectViewHeightConstraint = NSLayoutConstraint(item: textAreaVisualEffectView,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .Height,
                multiplier: 1,
                constant: 0)
            cornerView.addConstraints([textAreaVisualEffectViewTopConstraint, textAreaVisualEffectViewRightConstraint, textAreaVisualEffectViewLeftConstraint, textAreaVisualEffectViewHeightConstraint])
            
            let textAreaBackgroundViewTopConstraint = NSLayoutConstraint(item: textAreaBackgroundView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: cornerView,
                attribute: .Top,
                multiplier: 1,
                constant: 0)
            let textAreaBackgroundViewRightConstraint = NSLayoutConstraint(item: textAreaBackgroundView,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: cornerView,
                attribute: .Right,
                multiplier: 1,
                constant: 0)
            let textAreaBackgroundViewLeftConstraint = NSLayoutConstraint(item: textAreaBackgroundView,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: cornerView,
                attribute: .Left,
                multiplier: 1,
                constant: 0)
            textAreaBackgroundViewHeightConstraint = NSLayoutConstraint(item: textAreaBackgroundView,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .Height,
                multiplier: 1,
                constant: 0)
            cornerView.addConstraints([textAreaBackgroundViewTopConstraint, textAreaBackgroundViewRightConstraint, textAreaBackgroundViewLeftConstraint, textAreaBackgroundViewHeightConstraint])

        }
        
        deinit {
            Alert.NotificationManager.sharedInstance.removeAlertActionEnabledDidChangeNotificationObserver(self)
            Alert.NotificationManager.sharedInstance.removeKeyboardNotificationObserver(self)
        }
        
        /**
        User Setting
        */
        public func configure(overlayBackgroundColor backgroundColor: UIColor) {
            overlayBackgroundColor = backgroundColor
        }
        
        public func configure(backgroundColor backgroundColor: UIColor) {
            var color = backgroundColor
            let rgba = CGColorGetComponents(color.CGColor)
            if rgba[3] > 0.1 {
                color = UIColor(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: 0.1)
            }
            self.backgroundColor = color
        }

        public func configure(titleFont font: UIFont, textColor: UIColor) {
            titleFont = font
            titleColor = textColor
        }
        
        public func configure(messageFont font: UIFont, textColor: UIColor) {
            messageFont = font
            messageColor = textColor
        }
        
        public func configure(buttonFont buttonFont: [Alert.ActionStyle : UIFont!]? = nil, buttonTextColor: [Alert.ActionStyle : UIColor]? = nil, buttonDisableTextColor: [Alert.ActionStyle : UIColor]? = nil) {
            if buttonFont?[.Default] != nil {
                self.buttonFont[.Default] = buttonFont?[.Default]
            } else if buttonFont?[.Destructive] != nil {
                self.buttonFont[.Destructive] = buttonFont?[.Destructive]
            } else if buttonFont?[.Cancel] != nil {
                self.buttonFont[.Cancel] = buttonFont?[.Cancel]
            }
            if buttonTextColor?[.Default] != nil {
                self.buttonTextColor[.Default] = buttonTextColor?[.Default]
            } else if buttonTextColor?[.Destructive] != nil {
                self.buttonTextColor[.Destructive] = buttonTextColor?[.Destructive]
            } else if buttonTextColor?[.Cancel] != nil {
                self.buttonTextColor[.Cancel] = buttonTextColor?[.Cancel]
            }
            if buttonDisableTextColor?[.Default] != nil {
                self.buttonDisableTextColor[.Default] = buttonDisableTextColor?[.Default]
            } else if buttonDisableTextColor?[.Destructive] != nil {
                self.buttonDisableTextColor[.Destructive] = buttonDisableTextColor?[.Destructive]
            } else if buttonDisableTextColor?[.Cancel] != nil {
                self.buttonDisableTextColor[.Cancel] = buttonDisableTextColor?[.Cancel]
            }
        }
        
        public func configure(alertViewWidth width: CGFloat) {
            alertViewWidth = width
        }
        
        public func configure(cornerRadius cornerRadius: CGFloat) {
            self.cornerRadius = cornerRadius
        }
        
        public func configure(textFieldBorderColor textFieldBorderColor: UIColor) {
            self.textFieldBorderColor = textFieldBorderColor
        }
        
        public func configure(buttonHeight buttonHeight: CGFloat) {
            self.buttonHeight = buttonHeight
        }
        
        // Adds Action
        public func addAction(action: AlertAction) {
            // Error
            if action.style == .Cancel {
                for index in 0..<actions.count {
                    if actions[index].style == .Cancel {
                        fatalError("Can not be used plurality cancel button")
                    }
                }
            }

            action.tag = actions.count
            action.button?.tag = action.tag
            if action.style == .Cancel {
                cancelAction = action
                cancelActionTag = action.tag
            }
            actions.append(action)
            action.button?.setTitle(action.title, forState: .Normal)
            action.button?.enabled = action.enabled
            action.visualEffectView = UIVisualEffectView(effect: effect) as UIVisualEffectView
            action.visualEffectView?.userInteractionEnabled = false
        }
        
        // Adds UITextFields
        public func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField!) -> Void)? = nil) {
            if isActionSheet {
                fatalError("Not available")
            }
            let textField = UITextField()
            configurationHandler?(textField)
            textFields.append(textField)
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        // layout
        public override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            adjustLayout()
        }
        
        private func adjustLayout() {
            
            if !isNeedlayout {
                return
            }
            isNeedlayout = false
            
            overlayView.backgroundColor = overlayBackgroundColor
            alertView.layer.cornerRadius = cornerRadius
            alertView.clipsToBounds = true
            alertViewWidthConstraint.constant = alertViewWidth
            
            cornerView.layer.cornerRadius = cornerRadius
            cornerView.clipsToBounds = true

            var textAreaPositionY: CGFloat = 0
            textAreaPositionY += (margin * 2)
            let textAreaWidth = alertViewWidth - (margin * 4)
            
            if hasTitle {
                titleLabel.frame.size = CGSizeMake(textAreaWidth, 0)
                titleLabel.numberOfLines = 0
                titleLabel.textAlignment = .Center
                titleLabel.font = titleFont
                titleLabel.textColor = titleColor
                titleLabel.text = title
                titleLabel.sizeToFit()
                titleLabel.frame = CGRectMake(margin * 2, textAreaPositionY, textAreaWidth, titleLabel.frame.height)
                textAreaView.addSubview(titleLabel)
                textAreaPositionY += titleLabel.frame.height
            }
            
            if hasMessage {
                if hasTitle {
                    textAreaPositionY += margin
                }
                messageLabel.frame.size = CGSizeMake(textAreaWidth, 0)
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = .Center
                messageLabel.text = message
                messageLabel.font = messageFont
                messageLabel.textColor = messageColor
                messageLabel.sizeToFit()
                messageLabel.frame = CGRectMake(margin * 2, textAreaPositionY, textAreaWidth, messageLabel.frame.height)
                textAreaView.addSubview(messageLabel)
                textAreaPositionY += messageLabel.frame.height
            }
            
            if hasTextField {
                if hasTitle || hasMessage {
                    textAreaPositionY += margin
                }
                let textFieldsView = UIView()
                textFieldsView.backgroundColor = UIColor.whiteColor()
                textFieldsView.layer.cornerRadius = (cornerRadius / 2)
                textFieldsView.clipsToBounds = true
                let textFieldsViewWidth = textAreaWidth
                var textFieldsViewHeight: CGFloat = 0
                textFieldsView.frame = CGRectMake(margin * 2, textAreaPositionY + margin, textFieldsViewWidth, textFieldsViewHeight)
                for (index, textField) in textFields.enumerate() {
                    textField.frame = CGRectMake(margin, CGFloat(index) * textFieldHeight, textFieldsViewWidth - (2 * margin), textFieldHeight)
                    textFieldsView.addSubview(textField)
                    textFieldsViewHeight += textFieldHeight
                    if index > 0 {
                        let topBorder = CALayer()
                        topBorder.frame = CGRectMake(-margin, 0, textFieldsViewWidth + (margin * 2), thin)
                        topBorder.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).CGColor
                        textField.layer.sublayers = [topBorder]
                        textField.clipsToBounds = false
                    }
                }
                textFieldsView.layer.borderColor = textFieldBorderColor.CGColor
                textFieldsView.layer.borderWidth = thin
                textAreaView.addSubview(textFieldsView)
                textFieldsView.frame.size.height = textFieldsViewHeight
                textAreaPositionY += textFieldsView.frame.size.height
            }
            if hasTitle || hasMessage || hasTextField {
                textAreaPositionY += (margin * 2)
                textAreaBackgroundView.backgroundColor = backgroundColor
            } else {
                textAreaPositionY = 0
            }
            textAreaHeight = textAreaPositionY
            
            textAreaViewHeightConstraint.constant = textAreaHeight
            textAreaVisualEffectViewHeightConstraint.constant = textAreaHeight
            textAreaBackgroundViewHeightConstraint.constant = textAreaHeight
            
            var cornerViewHeight = textAreaHeight
            var alertViewHeight: CGFloat = 0
            
            // button setUp
            if isAlert && actions.count == 2 && (hasTitle || hasMessage || hasTextField) {
                cornerViewHeight += thin
                for index in 0..<actions.count {
                    let action = actions[index]
                    let rect = CGRectMake(CGFloat(index) * alertViewWidth / 2, cornerViewHeight, alertViewWidth / 2, buttonHeight)
                    action.backgroundView.frame = rect
                    action.backgroundView.backgroundColor = backgroundColor
                    action.visualEffectView?.frame = rect
                    action.button.frame = rect
                    if let visualEffectView = action.visualEffectView {
                        cornerView.addSubview(action.backgroundView)
                        cornerView.addSubview(visualEffectView)
                    }
                    action.button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                    action.button.setTitleColor(buttonDisableTextColor[action.style], forState: .Disabled)
                    action.button.titleLabel?.font = buttonFont[action.style]
                    if index == actions.count - 1 {
                        action.visualEffectView?.frame.origin.x += thin
                        action.visualEffectView?.frame.size.width -= thin
                        action.button.frame.origin.x += thin
                        action.button.frame.size.width -= thin
                    }
                    action.button.addTarget(self,
                        action: Selector("buttonWasTouchUpInside:"),
                        forControlEvents: .TouchUpInside)
                    cornerView.addSubview(action.button)
                }
                cornerViewHeight += buttonHeight
            } else if isAlert || isAlertVertical {
                for index in 0..<actions.count {
                    cornerViewHeight += thin
                    let action = actions[index]
                    let rect = CGRectMake(0, cornerViewHeight, alertViewWidth, buttonHeight)
                    action.backgroundView.frame = rect
                    action.backgroundView.backgroundColor = backgroundColor
                    action.visualEffectView?.frame = rect
                    action.button.frame = rect
                    if let visualEffectView = action.visualEffectView {
                        cornerView.addSubview(action.backgroundView)
                        cornerView.addSubview(visualEffectView)
                    }
                    action.button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                    action.button.setTitleColor(buttonDisableTextColor[action.style], forState: .Disabled)
                    action.button.titleLabel?.font = buttonFont[action.style]
                    action.button.addTarget(self,
                        action: Selector("buttonWasTouchUpInside:"),
                        forControlEvents: .TouchUpInside)
                    cornerView.addSubview(action.button)
                    cornerViewHeight += buttonHeight
                }
            } else {
                cornerViewHeight += thin
                var cancelIndex = -1
                for index in 0..<actions.count {
                    let action = actions[index]
                    if action.style == .Cancel {
                        cancelIndex = index
                    } else {
                        cornerViewHeight += thin
                        let rect = CGRectMake(0, cornerViewHeight, alertViewWidth, buttonHeight)
                        action.backgroundView.frame = rect
                        action.backgroundView.backgroundColor = backgroundColor
                        action.visualEffectView?.frame = rect
                        action.button.frame = rect
                        if let visualEffectView = action.visualEffectView {
                            cornerView.addSubview(action.backgroundView)
                            cornerView.addSubview(visualEffectView)
                        }
                        action.button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                        action.button.setTitleColor(buttonDisableTextColor[action.style], forState: .Disabled)
                        action.button.titleLabel?.font = buttonFont[action.style]
                        action.button.addTarget(self,
                            action: Selector("buttonWasTouchUpInside:"),
                            forControlEvents: .TouchUpInside)
                        cornerView.addSubview(action.button)
                        cornerViewHeight += buttonHeight
                    }
                }
                
                alertViewHeight = cornerViewHeight
                
                if cancelIndex >= 0 { // cancel
                    alertViewHeight += margin
                    let action = actions[cancelIndex]
                    let rect = CGRectMake(0, alertViewHeight, alertViewWidth, buttonHeight)
                    action.backgroundView.frame = rect
                    action.backgroundView.backgroundColor = backgroundColor
                    action.visualEffectView?.frame = rect
                    action.button.frame = rect
                    if let visualEffectView = action.visualEffectView {
                        alertView.addSubview(action.backgroundView)
                        alertView.addSubview(visualEffectView)
                    }
                    action.button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                    action.button.setTitleColor(buttonDisableTextColor[action.style], forState: .Disabled)
                    action.button.titleLabel?.font = buttonFont[action.style]
                    action.button.addTarget(self,
                        action: Selector("buttonWasTouchUpInside:"),
                        forControlEvents: .TouchUpInside)
                    
                    action.backgroundView.clipsToBounds = true
                    action.backgroundView.layer.cornerRadius = cornerRadius
                    action.visualEffectView?.clipsToBounds = true
                    action.visualEffectView?.layer.cornerRadius = cornerRadius
                    action.button.clipsToBounds = true
                    action.button.layer.cornerRadius = cornerRadius
                    
                    alertView.addSubview(action.button)
                    alertViewHeight += buttonHeight
                }
            }
            
            if isActionSheet {
                cornerViewHeightConstraint.constant = cornerViewHeight
            }
            
            if !isActionSheet {
                alertViewHeight = cornerViewHeight
            }
            alertViewHeightConstraint.constant = alertViewHeight
            view.layoutIfNeeded()
        }

        func respondsViewDidTouch(view: UIView) {
            if isActionSheet {
                guard let cancelAction = cancelAction else {
                    return
                }
                dismissViewControllerAnimated(true) {
                    cancelAction.handler?(cancelAction)
                }
            }
        }
        
        // Button Tapped Action
        private dynamic func buttonWasTouchUpInside(sender: UIButton) {
            sender.selected = true
            let action = actions[sender.tag]
            dismissViewControllerAnimated(true) {
                action.handler?(action)
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - TransitionAnimator
    public class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        private typealias TransitionAnimator = Alert.TransitionAnimator
        private static let presentBackAnimationDuration: NSTimeInterval = 0.45
        private static let dismissBackAnimationDuration: NSTimeInterval = 0.35
        
        private var goingPresent: Bool?
        
        init(present: Bool) {
            super.init()
            goingPresent = present
        }
        
        public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            if goingPresent == true {
                return TransitionAnimator.presentBackAnimationDuration
            } else {
                return TransitionAnimator.dismissBackAnimationDuration
            }
        }
        
        public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            if goingPresent == true {
                presentAnimation(transitionContext)
            } else {
                dismissAnimation(transitionContext)
            }
        }
        
        private func presentAnimation(transitionContext: UIViewControllerContextTransitioning) {
            if let alertController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? Alert.Controller,
                containerView = transitionContext.containerView() {
                    containerView.backgroundColor = UIColor.clearColor()
                    containerView.addSubview(alertController.view)
                    
                    alertController.overlayView.alpha = 0
                    
                    if alertController.isActionSheet {
                        alertController.alertView.transform = CGAffineTransformMakeTranslation(0, alertController.alertView.frame.height)
                    } else {
                        alertController.cornerView.subviews.forEach({ $0.alpha = 0 })
                        alertController.alertView.center = alertController.view.center
                        alertController.alertView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                    }
                    
                    UIView.animateWithDuration(transitionDuration(transitionContext) * (5 / 9),
                        animations: {
                            alertController.overlayView.alpha = 1
                            if alertController.isActionSheet {
                                alertController.alertView.transform = CGAffineTransformMakeTranslation(0, -10)
                            } else {
                                alertController.cornerView.subviews.forEach({ $0.alpha = 1 })
                                alertController.alertView.transform = CGAffineTransformMakeScale(1.05, 1.05)
                            }
                        },
                        completion: { finished in
                            if finished {
                                UIView.animateWithDuration(self.transitionDuration(transitionContext) * (4 / 9),
                                    animations: {
                                        alertController.alertView.transform = CGAffineTransformIdentity
                                    },
                                    completion: { finished in
                                        if finished {
                                            let cancelled = transitionContext.transitionWasCancelled()
                                            if cancelled {
                                                alertController.view.removeFromSuperview()
                                            }
                                            transitionContext.completeTransition(!cancelled)
                                        }
                                })
                            }
                    })
            } else {
                transitionContext.completeTransition(false)
            }
        }
        
        private func dismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
            if let alertController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? Alert.Controller {
                UIView.animateWithDuration(transitionDuration(transitionContext),
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .CurveEaseInOut,
                    animations: {
                        alertController.overlayView.alpha = 0
                        if alertController.isActionSheet {
                            alertController.containerView.transform = CGAffineTransformMakeTranslation(0, alertController.alertView.frame.height)
                        } else {
                            alertController.alertView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                            alertController.cornerView.subviews.forEach({ $0.alpha = 0 })
                        }
                    },
                    completion: { finished in
                        if finished {
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                        }
                })
            } else {
                transitionContext.completeTransition(false)
            }
            
        }
    }

    private class RespondsView: UIView {
        weak var delegate: PCLRespondsViewDelegate?
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
            super.touchesEnded(touches, withEvent: event)
            delegate?.respondsViewDidTouch(self)
        }
    }
    
    // MARK: - NotificationManager
    private class NotificationManager {
        private typealias Manager = Alert.NotificationManager
        private static let sharedInstance = Alert.NotificationManager()
        class func sharedManager() -> Alert.NotificationManager {
            return sharedInstance
        }
        private let notificationCenter = NSNotificationCenter.defaultCenter()
    }
    
}


// MARK: - PCLRespondsViewDelegate
protocol PCLRespondsViewDelegate: class {
    func respondsViewDidTouch(view: UIView)
}


// MARK: - UIViewControllerTransitioningDelegate
extension PCLBlurEffectAlert.Controller: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PCLBlurEffectAlert.TransitionAnimator(present: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PCLBlurEffectAlert.TransitionAnimator(present: false)
    }
    
}

// MARK: - NotificationManager
extension PCLBlurEffectAlert.Controller : PCLAlertKeyboardNotificationObserver, PCLAlertActionEnabledDidChangeNotificationObserver {

    func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
        containerViewBottomLayoutConstraint.constant = keyboardHeight
        UIView.animateWithDuration(0.3,
            animations: {
                self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String: NSValue] {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue().size
            keyboardHeight = keyboardSize.height
            containerViewBottomLayoutConstraint.constant = -keyboardHeight
            UIView.animateWithDuration(0.3,
                animations: {
                    self.view.layoutIfNeeded()
            })
        }
    }
    
    func didAlertActionEnabledDidChange(notification: NSNotification) {
        for index in 0..<actions.count {
            actions[index].button.enabled = actions[index].enabled
        }
    }
    
}

// MARK: - keyboard
protocol PCLAlertKeyboardNotificationObserver: class {
    func keyboardWillShow(notification: NSNotification)
    func keyboardWillHide(notification: NSNotification)
}

private extension PCLBlurEffectAlert.NotificationManager {
    
    func addKeyboardNotificationObserver(observer: PCLAlertKeyboardNotificationObserver) {
        notificationCenter.addObserver(observer, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(observer, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotificationObserver(observer: PCLAlertKeyboardNotificationObserver) {
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
protocol PCLAlertActionEnabledDidChangeNotificationObserver: class {
    func didAlertActionEnabledDidChange(notification: NSNotification)
}

private extension PCLBlurEffectAlert.NotificationManager {
    
    static let DidAlertActionEnabledDidChangeNotification = "DidAlertActionEnabledDidChangeNotification"
    
    func addAlertActionEnabledDidChangeNotificationObserver(observer: PCLAlertActionEnabledDidChangeNotificationObserver) {
        notificationCenter.addObserver(observer, selector: "didAlertActionEnabledDidChange:", name: Manager.DidAlertActionEnabledDidChangeNotification , object: nil)
    }
    
    func removeAlertActionEnabledDidChangeNotificationObserver(observer: PCLAlertActionEnabledDidChangeNotificationObserver) {
        notificationCenter.removeObserver(observer, name: Manager.DidAlertActionEnabledDidChangeNotification, object: nil)
    }
    
    func postAlertActionEnabledDidChangeNotification() {
        notificationCenter.postNotification(NSNotification(name: Manager.DidAlertActionEnabledDidChangeNotification, object: nil, userInfo: nil))
    }
}
