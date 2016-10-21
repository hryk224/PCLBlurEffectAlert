//
//  PCLBlurEffectAlert+Action.swift
//  PCLBlurEffectAlert
//
//  Created by yoshida hiroyuki on 2016/09/15.
//  Copyright © 2016年 hiroyuki yoshida. All rights reserved.
//

import UIKit

extension PCLBlurEffectAlert {
    open class AlertAction {
        var tag: Int = -1
        var title: String?
        var style: Alert.ActionStyle
        var handler: ((Alert.AlertAction?) -> Void)?
        open var enabled: Bool = true {
            didSet {
                if (oldValue != enabled) {
                    Alert.NotificationManager.shared.postAlertActionEnabledDidChangeNotification()
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
}
