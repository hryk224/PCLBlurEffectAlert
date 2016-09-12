//
//  PCLBlurEffectAlert.swift
//  Pods
//
//  Created by hryk224 on 2015/10/14.
//
//

import UIKit

open class PCLBlurEffectAlert {
    
    fileprivate typealias Alert = PCLBlurEffectAlert
    
    public enum ActionStyle : Int {
        case `default` = 0, cancel, destructive
    }
    
    open class AlertAction {
        var tag: Int = -1
        var title: String?
        var style: Alert.ActionStyle
        var handler: ((Alert.AlertAction?) -> Void)?
        open var enabled: Bool = true {
            didSet {
                if (oldValue != enabled) {
                    Alert.NotificationManager.sharedInstance.postAlertActionEnabledDidChangeNotification()
                }
            }
        }
        var button: UIButton!
        var visualEffectView: UIVisualEffectView?
        lazy var backgroundView = UIView()
        public init(title: String,
                    style: Alert.ActionStyle,
                    handler: ((Alert.AlertAction?) -> Void)?) {
            self.title = title
            self.style = style
            self.handler = handler
            let button = UIButton(type: .custom)
            button.tag = tag
            button.adjustsImageWhenHighlighted = false
            button.adjustsImageWhenDisabled = false
            button.layer.masksToBounds = true
            button.setTitle(title, for: .normal)
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.titleLabel?.textAlignment = .center
            self.button = button
        }
        
    }
    
    public enum ControllerStyle : Int {
        case actionSheet = 0, alert, alertVertical
    }
    
    open class Controller: UIViewController, PCLRespondsViewDelegate {
        
        fileprivate typealias Controller = Alert.Controller
        
        fileprivate var isNeedlayout = true
        
        fileprivate var message: String?
        fileprivate var textField: UITextField?
        fileprivate var style: Alert.ControllerStyle = .actionSheet
        fileprivate var effect: UIBlurEffect = UIBlurEffect(style: .extraLight)
        
        // actions
        fileprivate var actions: [AlertAction] = []
        fileprivate var cancelAction: AlertAction?
        fileprivate var cancelActionTag: Int?
        fileprivate var keyboardHeight: CGFloat = 0
        
        // textFields
        fileprivate(set) var textFields: [UITextField] = [UITextField]()
        
        var isActionSheet: Bool {
            return style == .actionSheet
        }
        var isAlert: Bool {
            return style == .alert
        }
        var isAlertVertical: Bool {
            return style == .alertVertical
        }
        
        fileprivate var hasTitle: Bool {
            return title?.isEmpty == false
        }
        
        fileprivate var hasMessage: Bool {
            return message?.isEmpty == false
        }
        
        fileprivate var hasTextField: Bool {
            return !textFields.isEmpty
        }
        
        // UI
        open var cornerRadius: CGFloat = 0
        open var thin: CGFloat = 1 / UIScreen.main.scale
        
        // OverlayView
        fileprivate let overlayView = UIView()
        fileprivate let tapGestureRecognizer = UITapGestureRecognizer()
        
        // ContainerView
        fileprivate let containerView = RespondsView()
        fileprivate var containerViewBottomLayoutConstraint: NSLayoutConstraint!
        
        // AlertView
        fileprivate let alertView = UIView()
        fileprivate var alertViewWidth: CGFloat = 0
        fileprivate var alertViewWidthConstraint: NSLayoutConstraint!
        fileprivate var alertViewHeightConstraint: NSLayoutConstraint!
        
        // CornerView
        fileprivate let cornerView = UIView()
        fileprivate var cornerViewHeightConstraint: NSLayoutConstraint!
        
        // textAreaView
        fileprivate let textAreaView = UIView()
        fileprivate var textAreaHeight: CGFloat = 0
        fileprivate var textAreaViewHeightConstraint: NSLayoutConstraint!
        fileprivate var textAreaVisualEffectView: UIVisualEffectView!
        fileprivate var textAreaVisualEffectViewHeightConstraint: NSLayoutConstraint!
        fileprivate let textAreaBackgroundView = UIView()
        fileprivate var textAreaBackgroundViewHeightConstraint: NSLayoutConstraint!
        
        // titleLabel
        fileprivate let titleLabel = UILabel()
        
        // messageLabel
        fileprivate let messageLabel = UILabel()
        
        // public
        open var margin: CGFloat = 8
        open var overlayBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        open var backgroundColor = UIColor(white: 1, alpha: 0.05)
        open var titleFont = UIFont.boldSystemFont(ofSize: 16)
        open var titleColor = UIColor.brown
        open var messageFont = UIFont.systemFont(ofSize: 14)
        open var messageColor = UIColor.black
        open var buttonFont: [Alert.ActionStyle : UIFont] = [
            .default : UIFont.systemFont(ofSize: 16),
            .cancel  : UIFont.systemFont(ofSize: 16),
            .destructive  : UIFont.systemFont(ofSize: 16)
        ]
        open var buttonTextColor: [Alert.ActionStyle : UIColor] = [
            .default : UIColor.black,
            .cancel  : UIColor.gray,
            .destructive  : UIColor.red
        ]
        open var buttonDisableTextColor: [Alert.ActionStyle : UIColor] = [
            .default : UIColor.black,
            .cancel  : UIColor.black,
            .destructive  : UIColor.red
        ]
        open var textFieldHeight: CGFloat = 32
        open var textFieldBorderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        open var buttonHeight: CGFloat = 44
        
        public convenience init(title: String?, message: String?, effect: UIBlurEffect = UIBlurEffect(style: .extraLight), style: Alert.ControllerStyle) {
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
            modalPresentationStyle = .overCurrentContext
            transitioningDelegate = self
            view.frame.size = UIScreen.main.bounds.size
            overlayView.frame = UIScreen.main.bounds
            view.insertSubview(overlayView, at: 0)
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
        
        
        fileprivate func configureConstraints() {
            containerView.translatesAutoresizingMaskIntoConstraints = false
            let containerViewTopConstraint = NSLayoutConstraint(item: containerView,
                                                                attribute: .top,
                                                                relatedBy: .equal,
                                                                toItem: view,
                                                                attribute: .top,
                                                                multiplier: 1,
                                                                constant: 0)
            let containerViewRightConstraint = NSLayoutConstraint(item: containerView,
                                                                  attribute: .right,
                                                                  relatedBy: .equal,
                                                                  toItem: view,
                                                                  attribute: .right,
                                                                  multiplier: 1,
                                                                  constant: 0)
            let containerViewLeftConstraint = NSLayoutConstraint(item: containerView,
                                                                 attribute: .left,
                                                                 relatedBy: .equal,
                                                                 toItem: view,
                                                                 attribute: .left,
                                                                 multiplier: 1,
                                                                 constant: 0)
            containerViewBottomLayoutConstraint = NSLayoutConstraint(item: containerView,
                                                                     attribute: .bottom,
                                                                     relatedBy: .equal,
                                                                     toItem: view,
                                                                     attribute: .bottom,
                                                                     multiplier: 1,
                                                                     constant: 0)
            view.addConstraints([containerViewTopConstraint, containerViewRightConstraint, containerViewLeftConstraint, containerViewBottomLayoutConstraint])
            
            alertView.translatesAutoresizingMaskIntoConstraints = false
            
            if isActionSheet {
                let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView,
                                                                    attribute: .centerX,
                                                                    relatedBy: .equal,
                                                                    toItem: containerView,
                                                                    attribute: .centerX,
                                                                    multiplier: 1,
                                                                    constant: 0)
                let alertViewBottomConstraint = NSLayoutConstraint(item: alertView,
                                                                   attribute: .bottom,
                                                                   relatedBy: .equal,
                                                                   toItem: containerView,
                                                                   attribute: .bottom,
                                                                   multiplier: 1,
                                                                   constant: -(margin))
                alertViewWidthConstraint = NSLayoutConstraint(item: alertView,
                                                              attribute: .width,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .width,
                                                              multiplier: 1,
                                                              constant: alertViewWidth)
                alertViewHeightConstraint = NSLayoutConstraint(item: alertView,
                                                               attribute: .height,
                                                               relatedBy: .equal,
                                                               toItem: nil,
                                                               attribute: .height,
                                                               multiplier: 1,
                                                               constant: 0)
                containerView.addConstraints([alertViewCenterXConstraint, alertViewBottomConstraint, alertViewWidthConstraint, alertViewHeightConstraint])
            } else {
                let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView,
                                                                    attribute: .centerX,
                                                                    relatedBy: .equal,
                                                                    toItem: containerView,
                                                                    attribute: .centerX,
                                                                    multiplier: 1,
                                                                    constant: 0)
                let alertViewCenterYConstraint = NSLayoutConstraint(item: alertView,
                                                                    attribute: .centerY,
                                                                    relatedBy: .equal,
                                                                    toItem: containerView,
                                                                    attribute: .centerY,
                                                                    multiplier: 1,
                                                                    constant: 0)
                alertViewWidthConstraint = NSLayoutConstraint(item: alertView,
                                                              attribute: .width,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .width,
                                                              multiplier: 1,
                                                              constant: alertViewWidth)
                alertViewHeightConstraint = NSLayoutConstraint(item: alertView,
                                                               attribute: .height,
                                                               relatedBy: .equal,
                                                               toItem: nil,
                                                               attribute: .height,
                                                               multiplier: 1,
                                                               constant: 0)
                containerView.addConstraints([alertViewCenterXConstraint, alertViewCenterYConstraint, alertViewWidthConstraint, alertViewHeightConstraint])
            }
            
            cornerView.translatesAutoresizingMaskIntoConstraints = false
            
            if isActionSheet {
                let cornerViewTopConstraint = NSLayoutConstraint(item: cornerView,
                                                                 attribute: .top,
                                                                 relatedBy: .equal,
                                                                 toItem: alertView,
                                                                 attribute: .top,
                                                                 multiplier: 1,
                                                                 constant: 0)
                let cornerViewRightConstraint = NSLayoutConstraint(item: cornerView,
                                                                   attribute: .right,
                                                                   relatedBy: .equal,
                                                                   toItem: alertView,
                                                                   attribute: .right,
                                                                   multiplier: 1,
                                                                   constant: 0)
                let cornerViewLeftConstraint = NSLayoutConstraint(item: cornerView,
                                                                  attribute: .left,
                                                                  relatedBy: .equal,
                                                                  toItem: alertView,
                                                                  attribute: .left,
                                                                  multiplier: 1,
                                                                  constant: 0)
                cornerViewHeightConstraint = NSLayoutConstraint(item: cornerView,
                                                                attribute: .height,
                                                                relatedBy: .equal,
                                                                toItem: nil,
                                                                attribute: .height,
                                                                multiplier: 1,
                                                                constant: 0)
                alertView.addConstraints([cornerViewTopConstraint, cornerViewRightConstraint, cornerViewLeftConstraint, cornerViewHeightConstraint])
            } else {
                let cornerViewTopConstraint = NSLayoutConstraint(item: cornerView,
                                                                 attribute: .top,
                                                                 relatedBy: .equal,
                                                                 toItem: alertView,
                                                                 attribute: .top,
                                                                 multiplier: 1,
                                                                 constant: 0)
                let cornerViewRightConstraint = NSLayoutConstraint(item: cornerView,
                                                                   attribute: .right,
                                                                   relatedBy: .equal,
                                                                   toItem: alertView,
                                                                   attribute: .right,
                                                                   multiplier: 1,
                                                                   constant: 0)
                let cornerViewLeftConstraint = NSLayoutConstraint(item: cornerView,
                                                                  attribute: .left,
                                                                  relatedBy: .equal,
                                                                  toItem: alertView,
                                                                  attribute: .left,
                                                                  multiplier: 1,
                                                                  constant: 0)
                let cornerViewBottomLayoutConstraint = NSLayoutConstraint(item: cornerView,
                                                                          attribute: .bottom,
                                                                          relatedBy: .equal,
                                                                          toItem: alertView,
                                                                          attribute: .bottom,
                                                                          multiplier: 1,
                                                                          constant: 0)
                alertView.addConstraints([cornerViewTopConstraint, cornerViewRightConstraint, cornerViewLeftConstraint, cornerViewBottomLayoutConstraint])
            }
            
            textAreaView.translatesAutoresizingMaskIntoConstraints = false
            textAreaVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
            textAreaBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            let textAreaViewTopConstraint = NSLayoutConstraint(item: textAreaView,
                                                               attribute: .top,
                                                               relatedBy: .equal,
                                                               toItem: cornerView,
                                                               attribute: .top,
                                                               multiplier: 1,
                                                               constant: 0)
            let textAreaViewRightConstraint = NSLayoutConstraint(item: textAreaView,
                                                                 attribute: .right,
                                                                 relatedBy: .equal,
                                                                 toItem: cornerView,
                                                                 attribute: .right,
                                                                 multiplier: 1,
                                                                 constant: 0)
            let textAreaViewLeftConstraint = NSLayoutConstraint(item: textAreaView,
                                                                attribute: .left,
                                                                relatedBy: .equal,
                                                                toItem: cornerView,
                                                                attribute: .left,
                                                                multiplier: 1,
                                                                constant: 0)
            textAreaViewHeightConstraint = NSLayoutConstraint(item: textAreaView,
                                                              attribute: .height,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .height,
                                                              multiplier: 1,
                                                              constant: 0)
            
            cornerView.addConstraints([textAreaViewTopConstraint, textAreaViewRightConstraint, textAreaViewLeftConstraint, textAreaViewHeightConstraint])
            
            let textAreaVisualEffectViewTopConstraint = NSLayoutConstraint(item: textAreaVisualEffectView,
                                                                           attribute: .top,
                                                                           relatedBy: .equal,
                                                                           toItem: cornerView,
                                                                           attribute: .top,
                                                                           multiplier: 1,
                                                                           constant: 0)
            let textAreaVisualEffectViewRightConstraint = NSLayoutConstraint(item: textAreaVisualEffectView,
                                                                             attribute: .right,
                                                                             relatedBy: .equal,
                                                                             toItem: cornerView,
                                                                             attribute: .right,
                                                                             multiplier: 1,
                                                                             constant: 0)
            let textAreaVisualEffectViewLeftConstraint = NSLayoutConstraint(item: textAreaVisualEffectView,
                                                                            attribute: .left,
                                                                            relatedBy: .equal,
                                                                            toItem: cornerView,
                                                                            attribute: .left,
                                                                            multiplier: 1,
                                                                            constant: 0)
            textAreaVisualEffectViewHeightConstraint = NSLayoutConstraint(item: textAreaVisualEffectView,
                                                                          attribute: .height,
                                                                          relatedBy: .equal,
                                                                          toItem: nil,
                                                                          attribute: .height,
                                                                          multiplier: 1,
                                                                          constant: 0)
            cornerView.addConstraints([textAreaVisualEffectViewTopConstraint, textAreaVisualEffectViewRightConstraint, textAreaVisualEffectViewLeftConstraint, textAreaVisualEffectViewHeightConstraint])
            
            let textAreaBackgroundViewTopConstraint = NSLayoutConstraint(item: textAreaBackgroundView,
                                                                         attribute: .top,
                                                                         relatedBy: .equal,
                                                                         toItem: cornerView,
                                                                         attribute: .top,
                                                                         multiplier: 1,
                                                                         constant: 0)
            let textAreaBackgroundViewRightConstraint = NSLayoutConstraint(item: textAreaBackgroundView,
                                                                           attribute: .right,
                                                                           relatedBy: .equal,
                                                                           toItem: cornerView,
                                                                           attribute: .right,
                                                                           multiplier: 1,
                                                                           constant: 0)
            let textAreaBackgroundViewLeftConstraint = NSLayoutConstraint(item: textAreaBackgroundView,
                                                                          attribute: .left,
                                                                          relatedBy: .equal,
                                                                          toItem: cornerView,
                                                                          attribute: .left,
                                                                          multiplier: 1,
                                                                          constant: 0)
            textAreaBackgroundViewHeightConstraint = NSLayoutConstraint(item: textAreaBackgroundView,
                                                                        attribute: .height,
                                                                        relatedBy: .equal,
                                                                        toItem: nil,
                                                                        attribute: .height,
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
        open func configure(overlayBackgroundColor backgroundColor: UIColor) {
            overlayBackgroundColor = backgroundColor
        }
        
        open func configure(backgroundColor: UIColor) {
            var color = backgroundColor
            if let rgba = color.cgColor.components, rgba.count > 2 {
                if rgba[3] > CGFloat(0.1) {
                    color = UIColor(red: (rgba[0]), green: (rgba[1]), blue: (rgba[2]), alpha: 0.1)
                }
            }
            self.backgroundColor = color
        }
        
        open func configure(titleFont font: UIFont, textColor: UIColor) {
            titleFont = font
            titleColor = textColor
        }
        
        open func configure(messageFont font: UIFont, textColor: UIColor) {
            messageFont = font
            messageColor = textColor
        }
        
        open func configure(buttonFont: [Alert.ActionStyle : UIFont?]? = nil, buttonTextColor: [Alert.ActionStyle : UIColor]? = nil, buttonDisableTextColor: [Alert.ActionStyle : UIColor]? = nil) {
            if let font = buttonFont?[.default] {
                self.buttonFont[.default] = font
            } else if let font = buttonFont?[.destructive] {
                self.buttonFont[.destructive] = font
            } else if let font = buttonFont?[.cancel] {
                self.buttonFont[.cancel] = font
            }
            if buttonTextColor?[.default] != nil {
                self.buttonTextColor[.default] = buttonTextColor?[.default]
            } else if buttonTextColor?[.destructive] != nil {
                self.buttonTextColor[.destructive] = buttonTextColor?[.destructive]
            } else if buttonTextColor?[.cancel] != nil {
                self.buttonTextColor[.cancel] = buttonTextColor?[.cancel]
            }
            if buttonDisableTextColor?[.default] != nil {
                self.buttonDisableTextColor[.default] = buttonDisableTextColor?[.default]
            } else if buttonDisableTextColor?[.destructive] != nil {
                self.buttonDisableTextColor[.destructive] = buttonDisableTextColor?[.destructive]
            } else if buttonDisableTextColor?[.cancel] != nil {
                self.buttonDisableTextColor[.cancel] = buttonDisableTextColor?[.cancel]
            }
        }
        
        open func configure(alertViewWidth width: CGFloat) {
            alertViewWidth = width
        }
        
        open func configure(cornerRadius: CGFloat) {
            self.cornerRadius = cornerRadius
        }
        
        open func configure(textFieldBorderColor: UIColor) {
            self.textFieldBorderColor = textFieldBorderColor
        }
        
        open func configure(buttonHeight: CGFloat) {
            self.buttonHeight = buttonHeight
        }
        
        // Adds Action
        open func addAction(_ action: AlertAction) {
            // Error
            if action.style == .cancel {
                if actions.filter({ $0.style == .cancel }).count > 0 {
                    fatalError("Can not be used plurality cancel button")
                }
            }
            action.tag = actions.count
            action.button?.tag = action.tag
            if action.style == .cancel {
                cancelAction = action
                cancelActionTag = action.tag
            }
            actions.append(action)
            action.button?.setTitle(action.title, for: .normal)
            action.button?.isEnabled = action.enabled
            action.visualEffectView = UIVisualEffectView(effect: effect) as UIVisualEffectView
            action.visualEffectView?.isUserInteractionEnabled = false
        }
        
        // Adds UITextFields
        open func addTextFieldWithConfigurationHandler(_ configurationHandler: ((UITextField?) -> Void)? = nil) {
            if isActionSheet {
                fatalError("Not available")
            }
            let textField = UITextField()
            configurationHandler?(textField)
            textFields.append(textField)
        }
        
        // layout
        open override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            adjustLayout()
        }
        
        fileprivate func adjustLayout() {
            
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
                titleLabel.frame.size = CGSize(width: textAreaWidth, height: 0)
                titleLabel.numberOfLines = 0
                titleLabel.textAlignment = .center
                titleLabel.font = titleFont
                titleLabel.textColor = titleColor
                titleLabel.text = title
                titleLabel.sizeToFit()
                titleLabel.frame = CGRect(x: margin * 2, y: textAreaPositionY, width: textAreaWidth, height: titleLabel.frame.height)
                textAreaView.addSubview(titleLabel)
                textAreaPositionY += titleLabel.frame.height
            }
            
            if hasMessage {
                if hasTitle {
                    textAreaPositionY += margin
                }
                messageLabel.frame.size = CGSize(width: textAreaWidth, height: 0)
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = .center
                messageLabel.text = message
                messageLabel.font = messageFont
                messageLabel.textColor = messageColor
                messageLabel.sizeToFit()
                messageLabel.frame = CGRect(x: margin * 2, y: textAreaPositionY, width: textAreaWidth, height: messageLabel.frame.height)
                textAreaView.addSubview(messageLabel)
                textAreaPositionY += messageLabel.frame.height
            }
            
            if hasTextField {
                if hasTitle || hasMessage {
                    textAreaPositionY += margin
                }
                let textFieldsView = UIView()
                textFieldsView.backgroundColor = UIColor.white
                textFieldsView.layer.cornerRadius = (cornerRadius / 2)
                textFieldsView.clipsToBounds = true
                let textFieldsViewWidth = textAreaWidth
                var textFieldsViewHeight: CGFloat = 0
                textFieldsView.frame = CGRect(x: margin * 2, y: textAreaPositionY + margin, width: textFieldsViewWidth, height: textFieldsViewHeight)
                textFields.enumerated().forEach { index, textField in
                    textField.frame = CGRect(x: margin, y: CGFloat(index) * textFieldHeight, width: textFieldsViewWidth - (2 * margin), height: textFieldHeight)
                    textFieldsView.addSubview(textField)
                    textFieldsViewHeight += textFieldHeight
                    if index > 0 {
                        let topBorder = CALayer()
                        topBorder.frame = CGRect(x: -margin, y: 0, width: textFieldsViewWidth + (margin * 2), height: thin)
                        topBorder.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
                        textField.layer.sublayers = [topBorder]
                        textField.clipsToBounds = false
                    }
                }
                textFieldsView.layer.borderColor = textFieldBorderColor.cgColor
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
                (0..<actions.count).forEach { index in
                    let action = actions[index]
                    let rect = CGRect(x: CGFloat(index) * alertViewWidth / 2, y: cornerViewHeight, width: alertViewWidth / 2, height: buttonHeight)
                    action.backgroundView.frame = rect
                    action.backgroundView.backgroundColor = backgroundColor
                    action.visualEffectView?.frame = rect
                    action.button.frame = rect
                    if let visualEffectView = action.visualEffectView {
                        cornerView.addSubview(action.backgroundView)
                        cornerView.addSubview(visualEffectView)
                    }
                    action.button.setTitleColor(buttonTextColor[action.style], for: .normal)
                    action.button.setTitleColor(buttonDisableTextColor[action.style], for: .disabled)
                    action.button.titleLabel?.font = buttonFont[action.style]
                    if index == actions.count - 1 {
                        action.visualEffectView?.frame.origin.x += thin
                        action.visualEffectView?.frame.size.width -= thin
                        action.button.frame.origin.x += thin
                        action.button.frame.size.width -= thin
                    }
                    action.button.addTarget(self, action: #selector(Controller.buttonWasTouchUpInside(_:)), for: .touchUpInside)
                    cornerView.addSubview(action.button)                    
                }
                cornerViewHeight += buttonHeight
            } else if isAlert || isAlertVertical {
                (0..<actions.count).forEach { index in
                    cornerViewHeight += thin
                    let action = actions[index]
                    let rect = CGRect(x: 0, y: cornerViewHeight, width: alertViewWidth, height: buttonHeight)
                    action.backgroundView.frame = rect
                    action.backgroundView.backgroundColor = backgroundColor
                    action.visualEffectView?.frame = rect
                    action.button.frame = rect
                    if let visualEffectView = action.visualEffectView {
                        cornerView.addSubview(action.backgroundView)
                        cornerView.addSubview(visualEffectView)
                    }
                    action.button.setTitleColor(buttonTextColor[action.style], for: .normal)
                    action.button.setTitleColor(buttonDisableTextColor[action.style], for: .disabled)
                    action.button.titleLabel?.font = buttonFont[action.style]
                    action.button.addTarget(self, action: #selector(Controller.buttonWasTouchUpInside(_:)), for: .touchUpInside)
                    cornerView.addSubview(action.button)
                    cornerViewHeight += buttonHeight
                }
            } else {
                cornerViewHeight += thin
                var cancelIndex = -1
                (0..<actions.count).forEach { index in
                    let action = actions[index]
                    switch action.style {
                    case .cancel:
                        cancelIndex = index
                    default:
                        cornerViewHeight += thin
                        let rect = CGRect(x: 0, y: cornerViewHeight, width: alertViewWidth, height: buttonHeight)
                        action.backgroundView.frame = rect
                        action.backgroundView.backgroundColor = backgroundColor
                        action.visualEffectView?.frame = rect
                        action.button.frame = rect
                        if let visualEffectView = action.visualEffectView {
                            cornerView.addSubview(action.backgroundView)
                            cornerView.addSubview(visualEffectView)
                        }
                        action.button.setTitleColor(buttonTextColor[action.style], for: .normal)
                        action.button.setTitleColor(buttonDisableTextColor[action.style], for: .disabled)
                        action.button.titleLabel?.font = buttonFont[action.style]
                        action.button.addTarget(self, action: #selector(Controller.buttonWasTouchUpInside(_:)), for: .touchUpInside)
                        cornerView.addSubview(action.button)
                        cornerViewHeight += buttonHeight
                    }
                }
                alertViewHeight = cornerViewHeight
                if cancelIndex >= 0 { // cancel
                    alertViewHeight += margin
                    let action = actions[cancelIndex]
                    let rect = CGRect(x: 0, y: alertViewHeight, width: alertViewWidth, height: buttonHeight)
                    action.backgroundView.frame = rect
                    action.backgroundView.backgroundColor = backgroundColor
                    action.visualEffectView?.frame = rect
                    action.button.frame = rect
                    if let visualEffectView = action.visualEffectView {
                        alertView.addSubview(action.backgroundView)
                        alertView.addSubview(visualEffectView)
                    }
                    action.button.setTitleColor(buttonTextColor[action.style], for: .normal)
                    action.button.setTitleColor(buttonDisableTextColor[action.style], for: .disabled)
                    action.button.titleLabel?.font = buttonFont[action.style]
                    action.button.addTarget(self, action: #selector(Controller.buttonWasTouchUpInside(_:)), for: .touchUpInside)
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
        
        func respondsViewDidTouch(_ view: UIView) {
            if isActionSheet {
                guard let cancelAction = cancelAction else {
                    return
                }
                dismiss(animated: true) {
                    cancelAction.handler?(cancelAction)
                }
            }
        }
        
        // Button Tapped Action
        fileprivate dynamic func buttonWasTouchUpInside(_ sender: UIButton) {
            sender.isSelected = true
            let action = actions[sender.tag]
            dismiss(animated: true) {
                action.handler?(action)
            }
        }
        
    }
    
    // MARK: - TransitionAnimator
    open class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        fileprivate typealias TransitionAnimator = Alert.TransitionAnimator
        fileprivate static let presentBackAnimationDuration: TimeInterval = 0.45
        fileprivate static let dismissBackAnimationDuration: TimeInterval = 0.35
        
        fileprivate var goingPresent: Bool?
        
        init(present: Bool) {
            super.init()
            goingPresent = present
        }
        
        open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            if goingPresent == true {
                return TransitionAnimator.presentBackAnimationDuration
            } else {
                return TransitionAnimator.dismissBackAnimationDuration
            }
        }
        
        open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            if goingPresent == true {
                presentAnimation(transitionContext)
            } else {
                dismissAnimation(transitionContext)
            }
        }
        
        fileprivate func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
            if let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? Alert.Controller {
                let containerView = transitionContext.containerView
                containerView.backgroundColor = UIColor.clear
                containerView.addSubview(alertController.view)
                alertController.overlayView.alpha = 0
                if alertController.isActionSheet {
                    alertController.alertView.transform = CGAffineTransform(translationX: 0, y: alertController.alertView.frame.height)
                } else {
                    alertController.cornerView.subviews.forEach({ $0.alpha = 0 })
                    alertController.alertView.center = alertController.view.center
                    alertController.alertView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }
                let animations = {
                    alertController.overlayView.alpha = 1
                    if alertController.isActionSheet {
                        alertController.alertView.transform = CGAffineTransform(translationX: 0, y: -10)
                    } else {
                        alertController.cornerView.subviews.forEach({ $0.alpha = 1 })
                        alertController.alertView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    }
                }
                UIView.animate(withDuration: transitionDuration(using: transitionContext) * (5 / 9), animations: animations) { finished in
                    if finished {
                        let animations = {
                            alertController.alertView.transform = CGAffineTransform.identity
                        }
                        UIView.animate(withDuration: self.transitionDuration(using: transitionContext) * (4 / 9), animations: animations) { finished in
                            if finished {
                                let cancelled = transitionContext.transitionWasCancelled
                                if cancelled {
                                    alertController.view.removeFromSuperview()
                                }
                                transitionContext.completeTransition(!cancelled)
                            }
                        }
                    }
                }
            } else {
                transitionContext.completeTransition(false)
            }
        }
        
        fileprivate func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
            if let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? Alert.Controller {
                let animations = {
                    alertController.overlayView.alpha = 0
                    if alertController.isActionSheet {
                        alertController.containerView.transform = CGAffineTransform(translationX: 0, y: alertController.alertView.frame.height)
                    } else {
                        alertController.alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        alertController.cornerView.subviews.forEach({ $0.alpha = 0 })
                    }
                }
                UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: animations) { finished in
                    if finished {
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    }
                }
            } else {
                transitionContext.completeTransition(false)
            }
        }
    }
    
    fileprivate class RespondsView: UIView {
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
    
    // MARK: - NotificationManager
    fileprivate class NotificationManager {
        fileprivate typealias Manager = Alert.NotificationManager
        fileprivate static let sharedInstance = Alert.NotificationManager()
        class func sharedManager() -> Alert.NotificationManager {
            return sharedInstance
        }
        fileprivate let notificationCenter = NotificationCenter.default
    }
}


// MARK: - PCLRespondsViewDelegate
protocol PCLRespondsViewDelegate: class {
    func respondsViewDidTouch(_ view: UIView)
}


// MARK: - UIViewControllerTransitioningDelegate
extension PCLBlurEffectAlert.Controller: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PCLBlurEffectAlert.TransitionAnimator(present: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PCLBlurEffectAlert.TransitionAnimator(present: false)
    }
    
}

// MARK: - NotificationManager
extension PCLBlurEffectAlert.Controller : PCLAlertKeyboardNotificationObserver, PCLAlertActionEnabledDidChangeNotificationObserver {
    
    func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
        containerViewBottomLayoutConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo as? [String: NSValue],
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue.size else {
            return
        }
        keyboardHeight = keyboardSize.height
        containerViewBottomLayoutConstraint.constant = -keyboardHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func didAlertActionEnabledDidChange(_ notification: Notification) {
        (0..<actions.count).forEach { actions[$0].button.isEnabled = actions[$0].enabled }
    }
    
}

// MARK: - keyboard
@objc protocol PCLAlertKeyboardNotificationObserver: class {
    func keyboardWillShow(_ notification: Notification)
    func keyboardWillHide(_ notification: Notification)
}

private extension PCLBlurEffectAlert.NotificationManager {
    
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

private extension PCLBlurEffectAlert.NotificationManager {
    
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
