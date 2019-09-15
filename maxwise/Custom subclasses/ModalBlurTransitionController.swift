//
//  ModalBlurTransitionController.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 5/26/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import Foundation
import UIKit

enum ModalTransitionType {
    case presentation
    case dismissal
}

class ModalBlurTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    
    private var modalTransitionType: ModalTransitionType?
    private let blurOverlay = UIVisualEffectView()
    
    private var transitionDuration: TimeInterval {
        guard let transitionType = modalTransitionType else { fatalError() }
        switch transitionType {
        case .presentation:
            return 0.44
        case .dismissal:
            return 0.32
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        modalTransitionType = .dismissal
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        modalTransitionType = .presentation
        return self
    }
}

extension ModalBlurTransitionController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionType = modalTransitionType else { fatalError() }
        
        let viewToTransition: UIView
        switch transitionType {
        case .presentation:
            viewToTransition = transitionContext.view(forKey: .to)!
        case .dismissal:
            viewToTransition = transitionContext.view(forKey: .from)!
        }
        
        let viewOffScreenState = {
            let offscreenY = viewToTransition.bounds.height
            viewToTransition.transform = CGAffineTransform.identity.translatedBy(x: 0, y: offscreenY)
        }
        
        let presentedState = {
            viewToTransition.transform = CGAffineTransform.identity
        }
        
        // Create blur animator and animations for modal states
        let blurAnimator = UIViewPropertyAnimator(duration: transitionDuration, curve: .easeInOut)
        
        let presentedBlurState = {
            self.blurOverlay.effect = UIBlurEffect(style: .light)
        }
        
        let dismissedBlurState = {
            self.blurOverlay.effect = nil
        }
        
        // Create an animator with appropriate parameters
        let animator: UIViewPropertyAnimator
        switch transitionType {
        case .presentation:
            animator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: 0.82)
        case .dismissal:
            animator = UIViewPropertyAnimator(duration: transitionDuration, curve: .easeIn)
        }
        
        switch transitionType {
        case .presentation:
            transitionContext.containerView.addSubview(blurOverlay)
            blurOverlay.fill(in: transitionContext.containerView)
            
            transitionContext.containerView.addSubview(viewToTransition)
            viewToTransition.fill(in: transitionContext.containerView)
            
            UIView.performWithoutAnimation(viewOffScreenState)
            animator.addAnimations(presentedState)
            blurAnimator.addAnimations(presentedBlurState)
        case .dismissal:
            animator.addAnimations(viewOffScreenState)
            blurAnimator.addAnimations(dismissedBlurState)
        }
        
        // When the animation finishes,
        // we tell the system that the animation has completed,
        // and clear out our transition type.
        animator.addCompletion { _ in
            transitionContext.completeTransition(true)
            self.modalTransitionType = nil
        }
        
        // ... and here's where we kick off the animation:
        animator.startAnimation()
        blurAnimator.startAnimation()
    }
}
