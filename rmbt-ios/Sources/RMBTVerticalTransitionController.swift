//
//  RMBTVerticalTransitionController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 24.09.14.
//  Copyright © 2014 SPECURE GmbH. All rights reserved.
//

import UIKit

///
class RMBTVerticalTransitionController: NSObject, UIViewControllerAnimatedTransitioning {

    ///
    var reverse = false

    ///
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    ///
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let endFrame: CGRect = transitionContext.initialFrame(for: fromViewController)

        transitionContext.containerView.addSubview(toViewController.view)

        toViewController.view.frame = endFrame.offsetBy(dx: 0, dy: (self.reverse ? 1 : -1) * toViewController.view.frame.size.height)

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toViewController.view.frame = endFrame
            fromViewController.view.frame = fromViewController.view.frame.offsetBy(dx: 0, dy: (self.reverse ? -1 : 1) * toViewController.view.frame.size.height)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
