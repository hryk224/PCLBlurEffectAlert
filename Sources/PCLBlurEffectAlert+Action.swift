//
//  PCLBlurEffectAlert+Action.swift
//  PCLBlurEffectAlert
//
//  Created by yoshida hiroyuki on 2016/09/15.
//  Copyright © 2016年 hiroyuki yoshida. All rights reserved.
//

import UIKit

public typealias PCLBlurEffectAlertAction = PCLBlurEffectAlert.Action

extension PCLBlurEffectAlert {
    open class Action {
        var tag: Int = -1
        var title: String?
        open var style: PCLBlurEffectAlert.ActionStyle
        var handler: ((PCLBlurEffectAlert.Action?) -> Void)?
        var button: UIButton!
        var visualEffectView: UIVisualEffectView?
        lazy var backgroundView: UIView = {
           return UIView()
        }()
        open var isEnabled: Bool = true {
            didSet {
                guard oldValue != isEnabled else { return }
                PCLBlurEffectAlert.NotificationManager.shared.postAlertActionEnabledDidChangeNotification()
            }
        }
        public init(title: String,
                    style: PCLBlurEffectAlert.ActionStyle,
                    handler: ((PCLBlurEffectAlert.Action?) -> Void)?) {
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
}
