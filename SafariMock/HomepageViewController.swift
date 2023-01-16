//
//  HomepageViewController.swift
//  SafariMock
//
//  Created by Junda Ai on 11/21/22.
//

import UIKit

class HomepageViewController: UIViewController {

    let startButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }

    func setupStartButton() {
        startButton.layer.cornerRadius = 8
        startButton.layer.cornerCurve = .continuous
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.setTitle("start", for: .normal)
        startButton.restorationIdentifier = "startButton"
        startButton.addTarget(self, action: #selector(startButtonDidPress), for: .touchUpInside)

        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func startButtonDidPress() {
//        webView.isHidden = false
////        let url = URL(string: "https://www.kagi.com")!
////        let url = URL(string: "https://github1s.com/lynoapp/")!
//        // swiftlint:disable:next line_length
//        let url = URL(string: "https://stil.kurir.rs/moda/157971/ovo-su-najstilizovanije-zene-sveta-koja-je-po-vama-br-1-anketa")!
//        webView.load(URLRequest(url: url))
    }
}
