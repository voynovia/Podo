//
//  SideMenuPresentationController.swift
//  Podo
//
//  Created by m3g0byt3 on 24/11/2017.
//  Copyright © 2017 m3g0byt3. All rights reserved.
//

import UIKit

class SideMenuPresentationController: UIPresentationController {
    
    private lazy var dimmingView: UIView? = { this in
        guard let container = self.containerView else { return nil }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedViewController))
        this.frame = container.frame
        this.backgroundColor = .black
        this.alpha = 0
        this.clipsToBounds = true
        this.addGestureRecognizer(tapGestureRecognizer)
        return this
    }(UIView())
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return UIScreen.main.bounds }
        return CGRect(x: 0, y: 0, width: container.frame.width * SideMenu.widthRatio,
                      height: container.frame.height)
    }
    
    override func presentationTransitionWillBegin() {
        dimmingView.map { containerView?.addSubview($0) }
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView?.alpha = 0.5
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView?.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView?.alpha = 0
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView?.removeFromSuperview()
        }
    }
    
    @objc private func dismissPresentedViewController() {
        presentedViewController.dismiss(animated: true)
    }
}
