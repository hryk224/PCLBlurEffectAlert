//
//  AlertController.swift
//  pecolly
//
//  Created by yoshida hiroyuki on 2015/08/21.
//

import UIKit

enum AlertControllerStyle : Int {
    case ActionSheet = 0, Alert
}

enum AlertActionStyle : Int {
    case Default = 0, Cancel, Destructive
}

final class AlertController: UIViewController {
    
    private typealias Me = AlertController
    private static let margin: CGFloat = 8
    
    // Title
    // User super
    
    // Message
    var message: String?
    
    // AlertController Style
    private(set) var preferredStyle: AlertControllerStyle?
    
    // OverlayView
    var overlayView = UIView()
    
    // ContainerView
    var containerView = RespondsView()
    private var containerViewBottomSpaceConstraint: NSLayoutConstraint!
    
    // AlertView
    var alertView = UIView()
    
    // TextAreaScrollView
    private var textAreaScrollView = UIScrollView()
    
    // TextAreaView
    private var textAreaView = UIView()
    private var textAreaHeight: CGFloat = 0
    
    // TextContainer
    private(set) var textContainer = UIView()
    private var textContainerHeightConstraint: NSLayoutConstraint!
    private let textContainerVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
    private var textContainerVisualEffectViewHeightConstraint: NSLayoutConstraint!
    
    // TitleLabel
    private var titleLabel = UILabel()
    
    // MessageLabel
    private var messageLabel = UILabel()
    
    // TextFieldContainerView
    private var textFieldContainerView = UIView()
    
    // ButtonAreaScrollView
    private var buttonAreaScrollView = UIScrollView()
    private var buttonAreaScrollViewHeightConstraint: NSLayoutConstraint!
    private var buttonAreaHeight: CGFloat = 0
    
    // ButtonAreaView
    private var buttonAreaView = UIView()
    
    // ButtonContainer
    private var buttonContainer = UIView()
    private var buttonContainerHeightConstraint: NSLayoutConstraint!
    
    // UI Value
    private let screenSize = UIScreen.mainScreen().bounds.size
    
    private var buttonHeight = CGFloat.min
    private var alertViewWidth = CGFloat.min
    private var alertViewPadding = CGFloat.min
    private var innerContentWidth = CGFloat.min
    private var buttonMargin = CGFloat.min
    private var cancelButtonMargin = CGFloat.min
    private var buttonCornerRadius = CGFloat.min
    private var buttonCornerRadiuses = CGSize.zero
    private var actionSheetBounceHeight = CGFloat.min
    private var alertViewHeightConstraint: NSLayoutConstraint!
    
    // TextFields
    private(set) var textFields: [TextField] = [TextField]()
    var textFieldHeight: CGFloat = 32
    
    // Actions
    private(set) var actions: [AlertAction] = [AlertAction]()
    
    // Buttons
    private(set) var buttons = [UIButton]()
    private(set) var visualEffectViews = [UIVisualEffectView]()
    
    // Status
    private var layoutFlg = false
    private var cancelButtonTag = 0
    private var keyboardHeight: CGFloat = 0
    
    // Color & Font
    
    // Alert
    var overlayColor = UIColor.Pecolly.blackColor(alpha: 0.3)
    var alertViewBackgroundgColor = UIColor.clearColor()
    var textContainerColor = UIColor.Pecolly.whiteColor(alpha: 0.3)
    var titleFont = UIFont.NotoSans.demiLight(16)
    var titleColor = UIColor.Pecolly.black55Color()
    var messageFont = UIFont.NotoSans.demiLight(14)
    var messageColor = UIColor.Pecolly.black30Color()
    var buttonFont: [AlertActionStyle : UIFont!] = [
        .Default : UIFont.NotoSans.demiLight(16),
        .Cancel  : UIFont.NotoSans.demiLight(16),
        .Destructive  : UIFont.NotoSans.demiLight(16)
    ]
    var buttonTextColor: [AlertActionStyle : UIColor] = [
        .Default : UIColor.Pecolly.black55Color(),
        .Cancel  : UIColor.Pecolly.black55Color(),
        .Destructive  : UIColor.Pecolly.redColor()
    ]
    var buttonDisableTextColor: [AlertActionStyle : UIColor] = [
        .Default : UIColor.Pecolly.black30Color(),
        .Cancel  : UIColor.Pecolly.black30Color(),
        .Destructive  : UIColor.Pecolly.redColor()
    ]
    
    var buttonBackgrondColor: [AlertActionStyle : UIColor] = [
        .Default : UIColor.Pecolly.whiteColor(alpha: 0.3),
        .Cancel  : UIColor.Pecolly.whiteColor(alpha: 0.3),
        .Destructive  : UIColor.Pecolly.whiteColor(alpha: 0.3)
    ]
    var textFieldColor = UIColor.Pecolly.whiteColor(alpha: 0.15)
    
    convenience init(preferredStyle: AlertControllerStyle) {
        self.init(title: nil, message: nil, preferredStyle: preferredStyle)
    }
    
    convenience init(title: String?, message: String?, preferredStyle: AlertControllerStyle) {
        self.init(nibName: nil, bundle: nil)
        
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        
        // 背景見えるように
        modalPresentationStyle = .OverCurrentContext
        transitioningDelegate = self
        
        // NotificationCenter
        NotificationManager.sharedManager().addAlertActionEnabledDidChangeNotificationObserver(self)
        NotificationManager.sharedManager().addKeyboardNotificationObserver(self)
        
        configUI()
        
        // View
        view.frame.size = screenSize
        // OverlayView
        view.addSubview(overlayView)
        // ContainerView
        view.addSubview(containerView)
        
        if isActionSheet() {
            containerView.delegate = self
        }
        
        // AlertView
        containerView.addSubview(alertView)
        
        // TextAreaScrollView
        textAreaScrollView.scrollEnabled = false // FIXME
        alertView.addSubview(textAreaScrollView)
        
        // TextAreaView
        textAreaScrollView.addSubview(textAreaView)
        
        // TextContainer
        textAreaView.addSubview(textContainer)
        textAreaView.insertSubview(textContainerVisualEffectView, belowSubview: textContainer)
        visualEffectViews.append(textContainerVisualEffectView)
        
        // ButtonAreaScrollView
        buttonAreaScrollView.scrollEnabled = false // FIXME
        alertView.addSubview(buttonAreaScrollView)
        
        // ButtonAreaView
        buttonAreaScrollView.addSubview(buttonAreaView)
        
        // ButtonContainer
        buttonAreaView.addSubview(buttonContainer)
        
        //------------------------------
        // Layout Constraint
        //------------------------------
        prepareConstraints()
        setConstraints()
        
    }
    
    deinit {
        NotificationManager.sharedManager().removeAlertActionEnabledDidChangeNotificationObserver(self)
        NotificationManager.sharedManager().removeKeyboardNotificationObserver(self)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AlertController: RespondsViewDelegate {
    
    func respondsViewDidTouch(view: UIView) {
        // cancel action
        guard let action = actions[safe: cancelButtonTag - 1] else {
            return
        }
        dismissViewControllerAnimated(true) {
            action.handler?(action)
        }
    }
    
}

// MARK: - Life cycle
extension AlertController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        layoutView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let textField = textFields[safe: 0] {
            textField.becomeFirstResponder()
        }
    }
}

// MARK: - override
extension AlertController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIApplication.sharedApplication().statusBarStyle
    }
    
}

// MARK: - public
extension AlertController {
    
    func isActionSheet() -> Bool {
        return preferredStyle == .ActionSheet
    }
    
    func isAlert() -> Bool {
        return preferredStyle == .Alert
    }
    
    // Attaches an action object to the alert or action sheet.
    func addAction(action: AlertAction) {
        
        // Error
        if action.style == .Cancel {
            if actions.count > 0 {
                // FIXME
                assert(false, "Cancelボタンは一個目に設置して下さい。")
            }
            for index in 0..<actions.count {
                if actions[index].style == .Cancel {
                    assert(false, "AlertController can only have one action with a style of AlertActionStyleCancel")
                    return
                }
            }
        }
        
        // Add Action
        actions.append(action)
        
        // Add Button
        let button = UIButton(type: .Custom)
        button.layer.masksToBounds = true
        button.setTitle(action.title, forState: .Normal)
        button.enabled = action.enabled
        button.addTarget(self,
            action: Selector("buttonWasTouchUpInside:"),
            forControlEvents: .TouchUpInside)
        button.tag = buttons.count + 1
        button.adjustsImageWhenHighlighted = false
        button.adjustsImageWhenDisabled = false
        buttons.append(button)
        buttonContainer.addSubview(button)
    }
    
    // Adds a text field to an alert.
    func addTextFieldWithConfigurationHandler(configurationHandler: ((TextField!) -> Void)? = nil) {
        
        // You can add a text field only if the preferredStyle property is set to AlertControllerStyle.Alert.
        if !isAlert() {
            assert(false, "Text fields can only be added to an alert controller of style AlertControllerStyleAlert")
            return
        }
        
        if textFields.count > 0 {
            assert(false, "TextFieldsは一個までに・・・")
            return
        }
        
        let textField = TextField()
        textField.leftMargin = 8
        textField.frame.size = CGSizeMake(innerContentWidth, textFieldHeight)
        textField.borderStyle = UITextBorderStyle.None
        textField.backgroundColor = textFieldColor
        
        configurationHandler?(textField)
        
        textFields.append(textField)
        textFieldContainerView.addSubview(textField)
    }
    
}

// MARK: - private
private extension AlertController {
    
    // Button Tapped Action
    dynamic func buttonWasTouchUpInside(sender: UIButton) {
        sender.selected = true
        let action = actions[sender.tag - 1]
        dismissViewControllerAnimated(true) {
            action.handler?(action)
        }
    }
    
    func configUI() {
        
        if isActionSheet() {
            
            titleFont = UIFont.NotoSans.demiLight(16)
            titleColor = UIColor.Pecolly.black55Color()
            messageFont = UIFont.NotoSans.demiLight(14)
            messageColor = UIColor.Pecolly.black30Color()
            buttonFont = [
                .Default : UIFont.NotoSans.demiLight(18),
                .Cancel  : UIFont.NotoSans.demiLight(18),
                .Destructive  : UIFont.NotoSans.demiLight(18)
            ]
            buttonTextColor = [
                .Default : UIColor.Pecolly.black55Color(),
                .Cancel  : UIColor.Pecolly.black55Color(),
                .Destructive  : UIColor.Pecolly.redColor()
            ]
            buttonDisableTextColor = [
                .Default : UIColor.Pecolly.black55Color(),
                .Cancel  : UIColor.Pecolly.black55Color(),
                .Destructive  : UIColor.Pecolly.redColor()
            ]
            buttonBackgrondColor = [
                .Default : UIColor.Pecolly.whiteColor(alpha: 0.3),
                .Cancel  : UIColor.Pecolly.whiteColor(alpha: 0.3),
                .Destructive  : UIColor.Pecolly.whiteColor(alpha: 0.3)
            ]
        }
        
        if isActionSheet() {
            buttonHeight = 44
            alertViewWidth =  screenSize.width
            alertViewPadding = Me.margin
            innerContentWidth = (screenSize.height > screenSize.width) ? screenSize.width - alertViewPadding * 2 : screenSize.height - alertViewPadding * 2
            buttonMargin = 0.5
            cancelButtonMargin = Me.margin - buttonMargin
            buttonCornerRadius = Const.CornerRadius
            buttonCornerRadiuses = CGSizeMake(buttonCornerRadius, buttonCornerRadius)
            actionSheetBounceHeight = 15 //仮
        } else {
            buttonHeight = 44
            alertViewWidth =  320 // 標準と似せる
            alertViewPadding = Me.margin
            innerContentWidth = alertViewWidth - 50 // 標準と似せる
            buttonMargin = 0.5
            buttonCornerRadius = Const.CornerRadius
            buttonCornerRadiuses = CGSizeMake(buttonCornerRadius, buttonCornerRadius)
            actionSheetBounceHeight = 0
        }
    }
    
    func prepareConstraints() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false
        textAreaScrollView.translatesAutoresizingMaskIntoConstraints = false
        textAreaView.translatesAutoresizingMaskIntoConstraints = false
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        textContainerVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        buttonAreaScrollView.translatesAutoresizingMaskIntoConstraints = false
        buttonAreaView.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstraints() {
        // overlayView & containerView
        let overlayViewTopSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let overlayViewRightSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        let overlayViewLeftSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        let overlayViewBottomSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        let containerViewTopSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let containerViewRightSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        let containerViewLeftSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        containerViewBottomSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraints([overlayViewTopSpaceConstraint, overlayViewRightSpaceConstraint, overlayViewLeftSpaceConstraint, overlayViewBottomSpaceConstraint, containerViewTopSpaceConstraint, containerViewRightSpaceConstraint, containerViewLeftSpaceConstraint, containerViewBottomSpaceConstraint])
        
        if isActionSheet() {
            // ContainerView
            let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView, attribute: .CenterX, relatedBy: .Equal, toItem: containerView, attribute: .CenterX, multiplier: 1, constant: 0)
            let alertViewBottomSpaceConstraint = NSLayoutConstraint(item: alertView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1, constant: actionSheetBounceHeight)
            let alertViewWidthConstraint = NSLayoutConstraint(item: alertView, attribute: .Width, relatedBy: .Equal, toItem: containerView, attribute: .Width, multiplier: 1, constant: 0)
            containerView.addConstraints([alertViewCenterXConstraint, alertViewBottomSpaceConstraint, alertViewWidthConstraint])
            
            // AlertView
            alertViewHeightConstraint = NSLayoutConstraint(item: alertView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 1000)
            alertView.addConstraint(alertViewHeightConstraint)
        } else {
            // ContainerView
            let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView, attribute: .CenterX, relatedBy: .Equal, toItem: containerView, attribute: .CenterX, multiplier: 1, constant: 0)
            let alertViewCenterYConstraint = NSLayoutConstraint(item: alertView, attribute: .CenterY, relatedBy: .Equal, toItem: containerView, attribute: .CenterY, multiplier: 1, constant: 0)
            containerView.addConstraints([alertViewCenterXConstraint, alertViewCenterYConstraint])
            
            // AlertView
            let alertViewWidthConstraint = NSLayoutConstraint(item: alertView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: alertViewWidth)
            alertViewHeightConstraint = NSLayoutConstraint(item: alertView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 1000)
            alertView.addConstraints([alertViewWidthConstraint, alertViewHeightConstraint])
        }
        
        // AlertView
        let textAreaScrollViewTopSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .Top, relatedBy: .Equal, toItem: alertView, attribute: .Top, multiplier: 1, constant: 0)
        let textAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .Right, relatedBy: .Equal, toItem: alertView, attribute: .Right, multiplier: 1, constant: 0)
        let textAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .Left, relatedBy: .Equal, toItem: alertView, attribute: .Left, multiplier: 1, constant: 0)
        let textAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .Bottom, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Top, multiplier: 1, constant: 0)
        let buttonAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .Right, relatedBy: .Equal, toItem: alertView, attribute: .Right, multiplier: 1, constant: 0)
        let buttonAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .Left, relatedBy: .Equal, toItem: alertView, attribute: .Left, multiplier: 1, constant: 0)
        let buttonAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .Bottom, relatedBy: .Equal, toItem: alertView, attribute: .Bottom, multiplier: 1, constant: isAlert() ? 0 : -actionSheetBounceHeight)
        alertView.addConstraints([textAreaScrollViewTopSpaceConstraint, textAreaScrollViewRightSpaceConstraint, textAreaScrollViewLeftSpaceConstraint, textAreaScrollViewBottomSpaceConstraint, buttonAreaScrollViewRightSpaceConstraint, buttonAreaScrollViewLeftSpaceConstraint, buttonAreaScrollViewBottomSpaceConstraint])
        
        // TextAreaScrollView
        let textAreaViewTopSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Top, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Top, multiplier: 1, constant: 0)
        let textAreaViewRightSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Right, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Right, multiplier: 1, constant: 0)
        let textAreaViewLeftSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Left, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Left, multiplier: 1, constant: 0)
        let textAreaViewBottomSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Bottom, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Bottom, multiplier: 1, constant: 0)
        let textAreaViewWidthConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Width, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Width, multiplier: 1, constant: 0)
        textAreaScrollView.addConstraints([textAreaViewTopSpaceConstraint, textAreaViewRightSpaceConstraint, textAreaViewLeftSpaceConstraint, textAreaViewBottomSpaceConstraint, textAreaViewWidthConstraint])
        
        // TextArea
        let textAreaViewHeightConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Height, relatedBy: .Equal, toItem: textContainer, attribute: .Height, multiplier: 1, constant: 0)
        let textContainerTopSpaceConstraint = NSLayoutConstraint(item: textContainer, attribute: .Top, relatedBy: .Equal, toItem: textAreaView, attribute: .Top, multiplier: 1, constant: 0)
        let textContainerCenterXConstraint = NSLayoutConstraint(item: textContainer, attribute: .CenterX, relatedBy: .Equal, toItem: textAreaView, attribute: .CenterX, multiplier: 1, constant: 0)
        let textContainerVisualEffectViewTopSpaceConstraint = NSLayoutConstraint(item: textContainerVisualEffectView, attribute: .Top, relatedBy: .Equal, toItem: textAreaView, attribute: .Top, multiplier: 1, constant: 0)
        let textContainerVisualEffectViewCenterXConstraint = NSLayoutConstraint(item: textContainerVisualEffectView, attribute: .CenterX, relatedBy: .Equal, toItem: textAreaView, attribute: .CenterX, multiplier: 1, constant: 0)
        textAreaView.addConstraints([textAreaViewHeightConstraint, textContainerTopSpaceConstraint, textContainerCenterXConstraint, textContainerVisualEffectViewTopSpaceConstraint, textContainerVisualEffectViewCenterXConstraint])
        
        // TextContainer
        let textContainerWidthConstraint = NSLayoutConstraint(item: textContainer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: innerContentWidth)
        textContainerHeightConstraint = NSLayoutConstraint(item: textContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 0)
        textContainer.addConstraints([textContainerWidthConstraint, textContainerHeightConstraint])
        
        let textContainerVisualEffectViewWidthConstraint = NSLayoutConstraint(item: textContainerVisualEffectView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: innerContentWidth)
        textContainerVisualEffectViewHeightConstraint = NSLayoutConstraint(item: textContainerVisualEffectView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 0)
        textContainerVisualEffectView.addConstraints([textContainerVisualEffectViewWidthConstraint, textContainerVisualEffectViewHeightConstraint])
        
        // ButtonAreaScrollView
        buttonAreaScrollViewHeightConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 0)
        let buttonAreaViewTopSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Top, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Top, multiplier: 1, constant: 0)
        let buttonAreaViewRightSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Right, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Right, multiplier: 1, constant: 0)
        let buttonAreaViewLeftSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Left, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Left, multiplier: 1, constant: 0)
        let buttonAreaViewBottomSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Bottom, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Bottom, multiplier: 1, constant: 0)
        let buttonAreaViewWidthConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Width, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Width, multiplier: 1, constant: 0)
        buttonAreaScrollView.addConstraints([buttonAreaScrollViewHeightConstraint, buttonAreaViewTopSpaceConstraint, buttonAreaViewRightSpaceConstraint, buttonAreaViewLeftSpaceConstraint, buttonAreaViewBottomSpaceConstraint, buttonAreaViewWidthConstraint])
        
        // ButtonArea
        let buttonAreaViewHeightConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Height, relatedBy: .Equal, toItem: buttonContainer, attribute: .Height, multiplier: 1, constant: 0)
        let buttonContainerTopSpaceConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .Top, relatedBy: .Equal, toItem: buttonAreaView, attribute: .Top, multiplier: 1, constant: 0)
        let buttonContainerCenterXConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .CenterX, relatedBy: .Equal, toItem: buttonAreaView, attribute: .CenterX, multiplier: 1, constant: 0)
        buttonAreaView.addConstraints([buttonAreaViewHeightConstraint, buttonContainerTopSpaceConstraint, buttonContainerCenterXConstraint])
        
        // ButtonContainer
        let buttonContainerWidthConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: innerContentWidth)
        buttonContainerHeightConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 0)
        buttonContainer.addConstraints([buttonContainerWidthConstraint, buttonContainerHeightConstraint])
    }
    
    func layoutView() {
        
        if layoutFlg {
            return
        }
        
        layoutFlg = true
        
        overlayView.backgroundColor = overlayColor
        alertView.backgroundColor = alertViewBackgroundgColor
        textContainer.backgroundColor = textContainerColor
        textContainerVisualEffectView.userInteractionEnabled = false
        
        //------------------------------
        // TextArea Layout
        //------------------------------
        let hasTitle: Bool = (title != nil) && (title!.characters.count > 0)
        let hasMessage: Bool = (message != nil) && message!.characters.count > 0
        let hasTextField: Bool = !(textFields.isEmpty)
        
        var textAreaPositionY: CGFloat = alertViewPadding * 2
        
        let textAreaWidth = innerContentWidth - (alertViewPadding * 4)
        
        // TitleLabel
        if hasTitle {
            titleLabel.frame.size = CGSizeMake(textAreaWidth, 0)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .Center
            titleLabel.font = titleFont
            titleLabel.textColor = titleColor
            titleLabel.text = title
            titleLabel.sizeToFit()
            titleLabel.frame = CGRectMake(alertViewPadding * 2, textAreaPositionY, textAreaWidth, titleLabel.frame.height)
            textContainer.addSubview(titleLabel)
            textAreaPositionY += titleLabel.frame.height + ((hasMessage) ? 4 : 0)
        }
        
        // MessageLabel
        if hasMessage {
            messageLabel.frame.size = CGSizeMake(innerContentWidth, 0)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .Center
            messageLabel.text = message
            messageLabel.font = messageFont
            messageLabel.textColor = messageColor
            messageLabel.sizeToFit()
            messageLabel.frame = CGRectMake(alertViewPadding * 2, textAreaPositionY, textAreaWidth, messageLabel.frame.height)
            textContainer.addSubview(messageLabel)
            textAreaPositionY += messageLabel.frame.height + ((hasTextField) ? 4 : 0)
        }
        
        // TextFieldContainerView
        if hasTextField {
            
            if (hasTitle || hasMessage) {
                textAreaPositionY += alertViewPadding
            }
            
            textFieldContainerView.backgroundColor = UIColor.clearColor()
            textFieldContainerView.layer.borderColor = UIColor.Pecolly.blackColor(alpha: 0.15).CGColor
            textFieldContainerView.layer.borderWidth = Const.BorderThin
            textFieldContainerView.layer.masksToBounds = true
            textFieldContainerView.cornerRadius()
            textContainer.addSubview(textFieldContainerView)
            
            var textFieldContainerHeight: CGFloat = 0
            
            // TextFields
            for (index, textField) in textFields.enumerate() {
                textField.frame = CGRectMake(4, textFieldContainerHeight, textAreaWidth - 8, textField.frame.height)
                textFieldContainerHeight += textField.frame.height + 0.5
                if index > 0 {
                    let topBorder = CALayer()
                    topBorder.frame = CGRectMake(0, 0, textAreaWidth, Const.BorderThin)
                    topBorder.backgroundColor = UIColor.Pecolly.blackColor(alpha: 0.15).CGColor
                    textField.layer.addSublayer(topBorder)
                }
            }
            
            textFieldContainerHeight -= 0.5
            textFieldContainerView.frame = CGRectMake(alertViewPadding * 2, textAreaPositionY, textAreaWidth, textFieldContainerHeight)
            textAreaPositionY += textFieldContainerHeight
        }
        
        if hasTitle || hasMessage || hasTextField {
            textAreaPositionY += (alertViewPadding * 2)
        }
        
        if !hasTitle && !hasMessage && !hasTextField {
            textAreaPositionY = 0
        }
        
        // TextAreaScrollView
        textAreaHeight = textAreaPositionY
        textAreaScrollView.contentSize = CGSizeMake(alertViewWidth, textAreaHeight)
        textContainerHeightConstraint.constant = textAreaHeight
        textContainerVisualEffectViewHeightConstraint.constant = textAreaHeight
        
        // タイトルエリアの角丸
        if hasTitle || hasMessage || hasTextField {
            let textContainerBounds = CGRectMake(0, 0, innerContentWidth, textAreaHeight)
            textContainer.layer.mask = CAShapeLayer.topMaskLayer(textContainerBounds, radii: buttonCornerRadiuses)
            textContainerVisualEffectView.layer.mask = CAShapeLayer.topMaskLayer(textContainerBounds, radii: buttonCornerRadiuses)
        }
        
        //------------------------------
        // ButtonArea Layout
        //------------------------------
        var buttonAreaPositionY: CGFloat = buttonMargin
        
        // Buttons
        if isAlert() && buttons.count == 2 {
            let buttonWidth = (innerContentWidth - buttonMargin) / 2
            var buttonPositionX: CGFloat = 0
            var index = 0
            for button in buttons {
                let action = actions[button.tag - 1]
                button.titleLabel?.font = buttonFont[action.style]
                button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                button.setTitleColor(buttonDisableTextColor[action.style], forState: .Disabled)
                button.setBackgroundColor(buttonBackgrondColor[action.style]!, forState: .Normal)
                button.frame = CGRectMake(buttonPositionX, buttonAreaPositionY, buttonWidth, buttonHeight)
                
                let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
                visualEffectView.frame = button.frame
                visualEffectView.userInteractionEnabled = false
                visualEffectViews.append(visualEffectView)
                buttonContainer.insertSubview(visualEffectView, belowSubview: button)
                if index == 0 {
                    button.layer.mask = CAShapeLayer.bottomLeftMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                    visualEffectView.layer.mask = CAShapeLayer.bottomLeftMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                } else {
                    button.layer.mask = CAShapeLayer.bottomRightMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                    visualEffectView.layer.mask = CAShapeLayer.bottomRightMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                }
                buttonPositionX += buttonMargin + buttonWidth
                index++
            }
            buttonAreaPositionY += buttonHeight
        } else {
            
            var index = 0
            for button in buttons {
                let action = actions[button.tag - 1]
                
                if (action.style != .Cancel) {
                    button.titleLabel?.font = buttonFont[action.style]
                    button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                    button.setBackgroundColor(buttonBackgrondColor[action.style]!, forState: .Normal)
                    button.frame = CGRectMake(0, buttonAreaPositionY, innerContentWidth, buttonHeight)
                    buttonAreaPositionY += buttonHeight + buttonMargin
                    
                    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
                    visualEffectView.frame = button.frame
                    visualEffectView.userInteractionEnabled = false
                    visualEffectViews.append(visualEffectView)
                    buttonContainer.insertSubview(visualEffectView, belowSubview: button)
                    
                    if buttons.count == 1 {
                        if hasTitle || hasMessage || hasTextField {
                            button.layer.mask = CAShapeLayer.bottomMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                            visualEffectView.layer.mask = CAShapeLayer.bottomMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                        } else {
                            button.cornerRadius(radius: buttonCornerRadius)
                            visualEffectView.cornerRadius(radius: buttonCornerRadius)
                        }
                    } else if buttons.count == 2 && index == 0 {
                        if index == 0 {
                            //キャンセル込でボタン2個の時
                            if let _ = buttonAreaScrollView.viewWithTag(cancelButtonTag) as? UIButton {
                                if !(hasTitle || hasMessage || hasTextField) {
                                    button.cornerRadius(radius: buttonCornerRadius)
                                    visualEffectView.cornerRadius(radius: buttonCornerRadius)
                                }
                            }
                        }
                    } else {
                        if index == 0 {
                            if !(hasTitle || hasMessage || hasTextField) {
                                button.layer.mask = CAShapeLayer.topMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                                visualEffectView.layer.mask = CAShapeLayer.topMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                            }
                        }
                    }
                    
                    index++ //キャンセルボタン以外の数
                } else {
                    cancelButtonTag = button.tag
                }
            }
            
            // ボタン複数でキャンセルボタンが無いとき、もしくはボタン複数でアクションシートの時は一番最後のボタンを丸くする
            if buttons.count > 1 && (isActionSheet() || cancelButtonTag == 0) {
                var button = buttons[buttons.count - 1]
                var visualEffectView = visualEffectViews[buttons.count - 1]
                if button.tag == cancelButtonTag {
                    button = buttons[buttons.count - 2]
                    visualEffectView = visualEffectViews[buttons.count - 2]
                }
                button.layer.mask = CAShapeLayer.bottomMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                visualEffectView.layer.mask = CAShapeLayer.bottomMaskLayer(button.bounds, radii: buttonCornerRadiuses)
            }
            
            // Cancel Button
            if cancelButtonTag != 0 {
                
                // キャンセルだけ少し離す
                if isActionSheet() && buttons.count > 1 {
                    buttonAreaPositionY += cancelButtonMargin
                }
                
                if let button = buttonAreaScrollView.viewWithTag(cancelButtonTag) as? UIButton {
                    let action = actions[cancelButtonTag - 1]
                    button.titleLabel?.font = buttonFont[action.style]
                    button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                    button.setBackgroundColor(buttonBackgrondColor[action.style]!, forState: .Normal)
                    button.frame = CGRectMake(0, buttonAreaPositionY, innerContentWidth, buttonHeight)
                    buttonAreaPositionY += buttonHeight + buttonMargin
                    
                    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
                    visualEffectView.frame = button.frame
                    visualEffectView.userInteractionEnabled = false
                    visualEffectViews.append(visualEffectView)
                    buttonContainer.insertSubview(visualEffectView, belowSubview: button)
                    
                    if (hasTitle || hasMessage || hasTextField) && isAlert() {
                        button.layer.mask = CAShapeLayer.bottomMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                        visualEffectView.layer.mask = CAShapeLayer.bottomMaskLayer(button.bounds, radii: buttonCornerRadiuses)
                    } else {
                        button.cornerRadius(radius: buttonCornerRadius)
                        visualEffectView.cornerRadius(radius: buttonCornerRadius)
                    }
                }
            }
            buttonAreaPositionY -= buttonMargin
        }
        
        // アクションシート最下部余白
        buttonAreaPositionY += alertViewPadding
        
        if (buttons.count == 0) {
            buttonAreaPositionY = 0
        }
        
        // ButtonAreaScrollView Height
        buttonAreaHeight = buttonAreaPositionY
        buttonAreaScrollView.contentSize = CGSizeMake(alertViewWidth, buttonAreaHeight)
        buttonContainerHeightConstraint.constant = buttonAreaHeight
        
        //------------------------------
        // AlertView Layout
        //------------------------------
        // AlertView Height
        reloadAlertViewHeight()
        alertView.frame.size = CGSizeMake(alertViewWidth, alertViewHeightConstraint.constant)
        
    }
    
    func reloadAlertViewHeight() {
        
        let maxHeight = screenSize.height - keyboardHeight
        
        // for avoiding constraint error
        buttonAreaScrollViewHeightConstraint.constant = 0
        
        // AlertView Height Constraint
        var alertViewHeight = textAreaHeight + buttonAreaHeight
        if alertViewHeight > maxHeight {
            alertViewHeight = maxHeight
        }
        if isActionSheet() {
            alertViewHeight += actionSheetBounceHeight
        }
        alertViewHeightConstraint.constant = alertViewHeight
        
        // ButtonAreaScrollView Height Constraint
        var buttonAreaScrollViewHeight = buttonAreaHeight
        if buttonAreaScrollViewHeight > maxHeight {
            buttonAreaScrollViewHeight = maxHeight
        }
        buttonAreaScrollViewHeightConstraint.constant = buttonAreaScrollViewHeight
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension AlertController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertTransitionModalAnimator(present: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertTransitionModalAnimator(present: false)
    }
    
}

// MARK: - AlertActionEnabledDidChangeNotificationObserver
extension AlertController: AlertActionEnabledDidChangeNotificationObserver {
    
    func didAlertActionEnabledDidChange(notification: NSNotification) {
        for index in 0..<buttons.count {
            buttons[index].enabled = actions[index].enabled
        }
    }
    
}

// MARK: - KeyboardNotificationObserver
extension AlertController: KeyboardNotificationObserver {
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String: NSValue] {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue().size
            keyboardHeight = keyboardSize.height
            reloadAlertViewHeight()
            containerViewBottomSpaceConstraint.constant = -keyboardHeight
            UIView.animateWithDuration(0.3,
                animations: {
                    self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
        reloadAlertViewHeight()
        containerViewBottomSpaceConstraint.constant = keyboardHeight
        UIView.animateWithDuration(0.3,
            animations: {
                self.view.layoutIfNeeded()
        })
    }
    
}








