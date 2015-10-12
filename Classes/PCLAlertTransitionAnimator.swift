//
//  PCLAlertTransitionAnimator.swift
//  PCLAlertController
//
//  Created by yoshida hiroyuki on 2015/10/12.
//  Copyright © 2015年 yoshida hiroyuki. All rights reserved.
//

import UIKit

class PCLAlertTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private typealias Me = PCLAlertTransitionAnimator
    private static let presentBackAnimationDuration: NSTimeInterval = 0.3
    private static let dismissBackAnimationDuration: NSTimeInterval = 0.3
    
    private var goingPresent: Bool?
    
    init(present: Bool) {
        super.init()
        goingPresent = present
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if goingPresent == true {
            return Me.presentBackAnimationDuration
        } else {
            return Me.dismissBackAnimationDuration
        }
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if goingPresent == true {
            presentAnimation(transitionContext)
        } else {
            dismissAnimation(transitionContext)
        }
    }
    
    private func presentAnimation(transitionContext: UIViewControllerContextTransitioning) {
        if let alertController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? PCLAlertController,
            containerView = transitionContext.containerView() {
                containerView.backgroundColor = UIColor.clearColor()

                alertController.overlayView.alpha = 0
                alertController.containerView.alpha = 0
                
                containerView.addSubview(alertController.view)
                
                UIView.animateWithDuration(transitionDuration(transitionContext) * (5 / 9),
                    animations: {
                        alertController.overlayView.alpha = 1
                        alertController.containerView.alpha = 1
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
        } else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    private func dismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
        if let alertController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? PCLAlertController {
            UIView.animateWithDuration(transitionDuration(transitionContext),
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: .CurveEaseInOut,
                animations: {
                    alertController.overlayView.alpha = 0
                    alertController.containerView.alpha = 0
                },
                completion: { finished in
                    if finished {
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                    }
            })
        } else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
    }
    
}
