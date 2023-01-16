//
//  URLTextField.swift
//  SafariMock
//
//  Created by Junda Ai on 11/22/22.
//

import UIKit

class URLTextField: UITextField {

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 5

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: UIConstants.URLTextFieldHeight),
            widthAnchor.constraint(equalToConstant: UIConstants.URLTextFieldWidth)
        ])
    }
}
