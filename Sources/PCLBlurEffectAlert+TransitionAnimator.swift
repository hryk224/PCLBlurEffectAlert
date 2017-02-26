//
//  PCLBlurEffectAlertController+Tr.swift
//  PCLBlurEffectAlert
//
//  Created by hiroyuki yoshida on 2017/02/26.
//
//

import UIKit

public typealias PCLBlurEffectAlertTransitionAnimator = PCLBlurEffectAlert.TransitionAnimator

extension PCLBlurEffectAlert {
    // MARK: - TransitionAnimator
    open class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        fileprivate typealias TransitionAnimator = PCLBlurEffectAlert.TransitionAnimator
        fileprivate static let presentBackAnimationDuration: TimeInterval = 0.45
        fileprivate static let dismissBackAnimationDuration: TimeInterval = 0.35
        fileprivate var goingPresent: Bool!
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
    }
}

// MARK: - Extension
private extension PCLBlurEffectAlert.TransitionAnimator {
    func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? PCLBlurEffectAlertController else {
            transitionContext.completeTransition(false)
            return
        }
        let containerView = transitionContext.containerView
        containerView.backgroundColor = .clear
        containerView.addSubview(alertController.view)
        alertController.overlayView.alpha = 0
        let animations: (() -> Void)
        switch alertController.style {
        case .actionSheet:
            alertController.alertView.transform = CGAffineTransform(translationX: 0,
                                                                    y: alertController.alertView.frame.height)
            animations = {
                alertController.overlayView.alpha = 1
                alertController.alertView.transform = CGAffineTransform(translationX: 0, y: -10)
            }
        default:
            alertController.cornerView.subviews.forEach { $0.alpha = 0 }
            alertController.alertView.center = alertController.view.center
            alertController.alertView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            animations = {
                alertController.overlayView.alpha = 1
                alertController.cornerView.subviews.forEach { $0.alpha = 1 }
                alertController.alertView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext) * (5 / 9), animations: animations) { finished in
            guard finished else { return }
            let animations = {
                alertController.alertView.transform = CGAffineTransform.identity
            }
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext) * (4 / 9), animations: animations) { finished in
                guard finished else { return }
                let cancelled = transitionContext.transitionWasCancelled
                if cancelled {
                    alertController.view.removeFromSuperview()
                }
                transitionContext.completeTransition(!cancelled)
            }
        }
    }
    func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? PCLBlurEffectAlertController else {
            transitionContext.completeTransition(false)
            return
        }
        let animations = {
            alertController.overlayView.alpha = 0
            switch alertController.style {
            case .actionSheet:
                alertController.containerView.transform = CGAffineTransform(translationX: 0,
                                                                            y: alertController.alertView.frame.height)
            default:
                alertController.alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                alertController.cornerView.subviews.forEach { $0.alpha = 0 }
            }
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: animations) { finished in
            guard finished else { return }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
