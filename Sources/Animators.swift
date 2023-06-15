//
//  Animators.swift
//  RMBT
//
//  Created by Tomas Baculák on 03/08/2017.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import Foundation

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)
        
        transitionContext.containerView.addSubview((toViewController?.view)!)
        
        toViewController?.view.alpha = 0.0
        toViewController?.navigationController?.navigationBar.isHidden = true
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                       animations: {  toViewController?.view.alpha = 1 },
                       completion: { _ in transitionContext.completeTransition(_:!transitionContext.transitionWasCancelled) })
    }
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toViewController   = transitionContext.viewController(forKey: .to)
        let fromViewController = transitionContext.viewController(forKey: .from)
        
        transitionContext.containerView.insertSubview((toViewController?.view)!, belowSubview: (fromViewController?.view)!)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                       animations: {  fromViewController?.view.alpha = 0.0 },
                       completion: { _ in transitionContext.completeTransition(_:!transitionContext.transitionWasCancelled) })
    }
}
