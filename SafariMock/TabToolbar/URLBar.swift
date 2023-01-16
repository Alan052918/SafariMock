//
//  URLBarView.swift
//  SafariMock
//
//  Created by Junda Ai on 11/21/22.
//

import Logging
import UIKit

protocol URLBarDelegate: AnyObject {
    var currentURL: URL? { get }
    var previousURL: URL? { get }
    var nextURL: URL? { get }

    func urlBar(_ urlBar: URLBar, didPan panGestureRecognizer: UIPanGestureRecognizer)
}

class URLBar: UIView {

    weak var delegate: URLBarDelegate!

    var currentURLTextField = URLTextField()
    var previousURLTextField = URLTextField()
    var nextURLTextField = URLTextField()

    let panGestureRecognizer = UIPanGestureRecognizer()

    private let logger = Logger(label: "URLBar")

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false

        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews() {
        [previousURLTextField, currentURLTextField, nextURLTextField].forEach { addSubview($0) }

        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(panBar(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }

    @objc
    func panBar(_ panGestureRecognizer: UIPanGestureRecognizer) {
        delegate?.urlBar(self, didPan: panGestureRecognizer)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            currentURLTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            currentURLTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            previousURLTextField.trailingAnchor.constraint(equalTo: currentURLTextField.leadingAnchor, constant: -10),
            previousURLTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            nextURLTextField.leadingAnchor.constraint(equalTo: currentURLTextField.trailingAnchor, constant: 10),
            nextURLTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func updateURLTextFields() {
        previousURLTextField.isHidden = false
        nextURLTextField.isHidden = false
//        if let previousURL = delegate?.previousURL {
//            previousURLTextField.text = previousURL.absoluteString
//            previousURLTextField.isHidden = false
//        }
//        if let nextURL = delegate?.nextURL {
//            nextURLTextField.text = nextURL.absoluteString
//            nextURLTextField.isHidden = false
//        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension URLBar: UIGestureRecognizerDelegate {

}
