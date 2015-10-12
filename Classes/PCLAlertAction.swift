//
//  PCLAlertAction.swift
//  Pods
//
//  Created by yoshida hiroyuki on 2015/10/12.
//
//

import UIKit

public enum PCLAlertActionStyle : Int {
    case Default = 0, Cancel, Destructive
}

public class PCLAlertAction {

    var title: String?
    var style: PCLAlertActionStyle
    var handler: ((PCLAlertAction!) -> Void)?
    var enabled: Bool {
        didSet {
            if (oldValue != enabled) {
                PCLNotificationManager.sharedManager().postAlertActionEnabledDidChangeNotification()
            }
        }
    }
    
    public required init(title: String,
        style: PCLAlertActionStyle,
        handler: ((PCLAlertAction!) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
        self.enabled = true
    }
    
}

public class PCLAlertActionView: UIView {
    
    public override var tag: Int {
        didSet {
            button.tag = tag
            visualEffectView.tag = tag
        }
    }
    
    var button: UIButton!
    var visualEffectView: UIVisualEffectView!
    
    init() {
        super.init(frame: CGRectZero)
    }
    
    public convenience init(action: PCLAlertAction, effect: UIBlurEffect) {
        self.init()
        visualEffectView = UIVisualEffectView(effect: effect) as UIVisualEffectView
        visualEffectView.userInteractionEnabled = false
        visualEffectView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleWidth]
        addSubview(visualEffectView)
        button = UIButton(type: .Custom)
        button.userInteractionEnabled = false
        button.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleWidth]
        button.layer.masksToBounds = true
        button.setTitle(action.title, forState: .Normal)
        button.enabled = action.enabled
        button.adjustsImageWhenHighlighted = false
        button.adjustsImageWhenDisabled = false
        addSubview(button)
        userInteractionEnabled = false
        backgroundColor = UIColor.clearColor()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}






