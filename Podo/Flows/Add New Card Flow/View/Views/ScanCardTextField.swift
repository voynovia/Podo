//
//  ScanCardTextField.swift
//  Podo
//
//  Created by m3g0byt3 on 28/03/2018.
//  Copyright © 2018 m3g0byt3. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
final class ScanCardTextField: UITextField {

    // MARK: - Typealiases

    typealias ButtonHandler = (UITextField) -> Void

    // MARK: - Constants

    private static let overlayViewOffset: CGFloat = 4.0
    private static let placeholderLabelKeypath = "_placeholderLabel"
    private static let scaleFactor: CGFloat = 0.5

    // MARK: - Properties

    var buttonHandler: ButtonHandler?

    @IBInspectable
    var isScanButtonHidden: Bool = false {
        didSet {
            rightViewMode = isScanButtonHidden ? .never : .always
        }
    }

    override var placeholder: String? {
        didSet {
            setupPlaceholder()
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Public API

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let initialRect = super.rightViewRect(forBounds: bounds)
        let offset: CGFloat = type(of: self).overlayViewOffset
        let size = CGSize(width: bounds.height - offset, height: bounds.height - offset)
        return CGRect(origin: initialRect.origin, size: size)
    }

    // MARK: - Private API

    private func setup() {
        let button = UIButton(type: .custom)
        button.setImage(R.image.scanCard(), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        rightView = button
        rightViewMode = .always
    }

    private func setupPlaceholder() {
        if let placeholderLabel = value(forKey: type(of: self).placeholderLabelKeypath) as? UILabel {
            placeholderLabel.adjustsFontSizeToFitWidth = true
            placeholderLabel.minimumScaleFactor = type(of: self).scaleFactor
        }
    }

    // MARK: - Control handlers

    @objc private func buttonAction() {
        buttonHandler?(self)
    }
}
