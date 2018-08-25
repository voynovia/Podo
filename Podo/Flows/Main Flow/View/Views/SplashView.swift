//
//  SplashView.swift
//  Podo
//
//  Created by m3g0byt3 on 22/08/2018.
//  Copyright © 2018 m3g0byt3. All rights reserved.
//

import Foundation
import UIKit

final class SplashView: UIView {

    // MARK: - Constants

    static let fillRule = "even-odd"
    static let fillMode = "forwards"
    static let scaleKeyPath = "transform.scale"
    static let colorKeyPath = "backgroundColor"
    static let alphaValue: CGFloat = 0
    static let outerRectScale: CGFloat = 3.0
    static let imageInset: CGFloat = -2
    static let dimmingDelayRatio = 0.3
    static let scaleTiming = CAMediaTimingFunction(controlPoints: 0.3, -0.20, 0.55, 0.33)
    private static let innerRectScale: CGFloat = 0.2
    private static let scaleToValue = 10.0

    // MARK: - Private properties

    // swiftlint:disable:next strict_fileprivate
    fileprivate static var wasShown = false

    // MARK: - Initialization

    override private init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable, message:
    """
    This class cannot be instantiated from StoryBoard/XIB,
    use \"show(for:image:outerColor:innerColor:completion:)\" instead.
    """)
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class cannot be instantiated from StoryBoard/XIB")
    }

    // MARK: - Public API

    static func show(for duration: TimeInterval,
                     image: UIImage,
                     outerColor: UIColor? = .black,
                     innerColor: UIColor? = .white,
                     completion: Completion? = nil) {

        // Early exit if splash view was shown already
        guard !wasShown else { return }

        // MARK: - Create required instances

        guard let baseRect = UIApplication.shared.keyWindow?.frame else { return }
        let maskView = UIView(frame: baseRect)
        let dimmingView = SplashView(frame: baseRect)
        let dimmingDelay = duration * SplashView.dimmingDelayRatio
        let dimmingToValue = innerColor?.withAlphaComponent(SplashView.alphaValue).cgColor
        let imageMaskLayer = CALayer()
        let shapeMaskLayer = CAShapeLayer()
        let innerRect = baseRect.scaledBy(dx: SplashView.innerRectScale, dy: SplashView.innerRectScale)
        let outerRect = baseRect.scaledBy(dx: SplashView.outerRectScale, dy: SplashView.outerRectScale)
        let innerPath = UIBezierPath(rect: innerRect)
        let outerPath = UIBezierPath(rect: outerRect)
        guard let shapeMaskPath = UIBezierPath(paths: outerPath, innerPath) else { return }

        // MARK: - Setup inner mask (masked by the image)

        // Small insents equal 1pt on the each side to prevent
        // some visual glithes while layer scaled animatedly
        imageMaskLayer.frame = innerRect.insetBy(dx: SplashView.imageInset, dy: SplashView.imageInset)
        imageMaskLayer.contents = image.cgImage

        // MARK: - Setup outer mask (masked by the path)

        shapeMaskLayer.frame = baseRect
        shapeMaskLayer.path = shapeMaskPath.cgPath
        shapeMaskLayer.fillRule = SplashView.fillRule
        shapeMaskLayer.addSublayer(imageMaskLayer)

        // MARK: - Setup mask view

        maskView.backgroundColor = outerColor
        maskView.layer.mask = shapeMaskLayer

        // MARK: - Setup dimming view (placed below mask view)

        dimmingView.backgroundColor = innerColor
        dimmingView.addSubview(maskView)

        // MARK: - Setup animations

        let scaleAnimation = CABasicAnimation(keyPath: SplashView.scaleKeyPath)
        scaleAnimation.toValue = SplashView.scaleToValue
        scaleAnimation.duration = duration
        scaleAnimation.timingFunction = SplashView.scaleTiming
        scaleAnimation.fillMode = SplashView.fillMode
        scaleAnimation.isRemovedOnCompletion = false

        let dimmingAnimation = CABasicAnimation(keyPath: SplashView.colorKeyPath)
        dimmingAnimation.toValue = dimmingToValue
        // Convert absolute time to the layer's time space
        dimmingAnimation.beginTime = dimmingView.layer.currentTime + dimmingDelay
        dimmingAnimation.duration = duration - dimmingDelay
        dimmingAnimation.fillMode = SplashView.fillMode
        dimmingAnimation.isRemovedOnCompletion = false
        dimmingAnimation.delegate = AnimationDelegate(dimmingView, completion: completion)

        // MARK: - Apply animations

        shapeMaskLayer.add(scaleAnimation, forKey: SplashView.scaleKeyPath)
        dimmingView.layer.add(dimmingAnimation, forKey: SplashView.colorKeyPath)

        // MARK: - Add view to hierarchy

        UIApplication.shared.keyWindow?.addSubview(dimmingView)
    }
}

/// Lightweight helper to avoid retain cycle between an `CAAnimation` instance and its delegate.
private class AnimationDelegate: NSObject, CAAnimationDelegate {

    // MARK: - Private properties

    private weak var view: UIView?
    private var completion: Completion?

    // MARK: - Initialization

    init(_ viewToRemove: UIView, completion: Completion? = nil) {
        self.view = viewToRemove
        self.completion = completion
    }

    // MARK: - CAAnimationDelegate protocol conformance

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        view?.removeFromSuperview()
        SplashView.wasShown = true
        completion?()
    }
}
