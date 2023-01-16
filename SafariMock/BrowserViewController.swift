//
//  ViewController.swift
//  SafariMock
//
//  Created by Junda Ai on 11/20/22.
//

import Logging
import UIKit
import WebKit

class BrowserViewController: UIViewController {

    let baseBlurredView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView()
        visualEffectView.effect = UIBlurEffect(style: .systemMaterial)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()

    let tabContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var tabToolbar = TabToolbar()
    private var tabToolbarExtendedHeightConstraint: NSLayoutConstraint!
    private var tabToolbarDefaultHeightConstraint: NSLayoutConstraint!
    private var tabToolbarCompactHeightConstraint: NSLayoutConstraint!

    var urlBar = URLBar()
    private var urlBarIsHidden: NSKeyValueObservation!

    let tabManager: TabManager

    var currentURL: URL? {
        return tabManager.selectedTab?.url
    }
    var previousURL: URL? {
        return tabManager.previousOfSelectedTab?.url
    }
    var nextURL: URL? {
        return tabManager.nextOfSelectedTab?.url
    }

    private let logger = Logger(label: "BrowserViewController")

    init(tabManager: TabManager) {
        self.tabManager = tabManager

        super.init(nibName: nil, bundle: nil)

        UIView.setAnimationsEnabled(true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        setupSubviews()
        setupConstraints()
        setupKVO()
    }

    func setupSubviews() {
        view.addSubview(baseBlurredView)

        view.addSubview(tabContainer)

        tabToolbar.tabToolbarDelegate = self
        view.addSubview(tabToolbar)

        urlBar.delegate = self
        view.addSubview(urlBar)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            baseBlurredView.topAnchor.constraint(equalTo: view.topAnchor),
            baseBlurredView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            baseBlurredView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseBlurredView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            tabContainer.topAnchor.constraint(equalTo: view.topAnchor),
            tabContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tabToolbarExtendedHeightConstraint = tabToolbar
            .heightAnchor
            .constraint(equalToConstant: UIConstants.TabToolbarExtendedHeight)
        tabToolbarDefaultHeightConstraint = tabToolbar
            .heightAnchor
            .constraint(equalToConstant: UIConstants.TabToolbarDefaultHeight)
        tabToolbarCompactHeightConstraint = tabToolbar
            .heightAnchor
            .constraint(equalToConstant: UIConstants.TabToolbarCompactHeight)
        NSLayoutConstraint.activate([
            tabToolbarExtendedHeightConstraint,
            tabToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            urlBar.topAnchor.constraint(equalTo: tabToolbar.topAnchor),
            urlBar.heightAnchor.constraint(equalToConstant: UIConstants.URLBarHeight),
            urlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setupKVO() {
        urlBarIsHidden = urlBar.observe(\.isHidden) { [self] (urlBar, _) in
            if urlBar.isHidden,
               tabToolbarExtendedHeightConstraint.constant == UIConstants.TabToolbarExtendedHeight {
                logger.info("url bar hides")
                tabToolbarExtendedHeightConstraint.isActive = false
                tabToolbarDefaultHeightConstraint.isActive = true
                tabToolbar.state = .tabsGrid
                UIView.animate(withDuration: 1/3, delay: 0, options: .curveEaseIn, animations: { [self] in
                    view.layoutIfNeeded()
                })
            }
            if !urlBar.isHidden,
               tabToolbarExtendedHeightConstraint.constant == UIConstants.TabToolbarDefaultHeight {
                logger.info("url bar appears")
                tabToolbarDefaultHeightConstraint.isActive = false
                tabToolbarExtendedHeightConstraint.isActive = true
                tabToolbar.state = .selectedTab
                UIView.animate(withDuration: 1/3, delay: 0, options: .curveEaseIn, animations: { [self] in
                    view.layoutIfNeeded()
                })
            }
        }
    }
}

// MARK: - TabDelegate

extension BrowserViewController: TabDelegate {

    func tab(_ tab: Tab, didCreateWebView webView: WKWebView) {
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: tabContainer.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor)
        ])
    }

    func tab(_ tab: Tab, willDeleteWebView webView: WKWebView) {
        webView.uiDelegate = nil
        webView.removeFromSuperview()
    }
}

// MARK: - TabManagerDelegate

extension BrowserViewController: TabManagerDelegate {

    func tabManager(_ tabManager: TabManagerProtocol, didSelect tab: Tab, after previousTab: Tab?) {
        if let webView = tab.webView {
            tabContainer.addSubview(webView)
        }
        tabToolbar.updateButtonItemState(canGoBack: tab.canGoBack)
        tabToolbar.updateButtonItemState(canGoForward: tab.canGoForward)
    }

    func tabManager(_ tabManager: TabManagerProtocol, didAdd tab: Tab, after previousTab: Tab?) {
        tab.delegate = self
    }
}

// MARK: - TabToolbarDelegate

extension BrowserViewController: TabToolbarDelegate {

    func tabToolbar(_ tabToolbar: TabToolbar, didPress buttonItem: TabToolbarButtonItem) {
        switch tabToolbar.state {
        case .selectedTab:
            selectedTabToolbar(tabToolbar, didPress: buttonItem)
        case .tabsGrid:
            gridTabsToolbar(tabToolbar, didPress: buttonItem)
        default:
            logger.critical("Invalid tabToolbar.state: \(String(describing: tabToolbar.state))")
        }
    }

    func selectedTabToolbar(_ tabToolbar: TabToolbar, didPress buttonItem: TabToolbarButtonItem) {
        switch buttonItem.operation {
        case .goBack:
            guard let selectedTab = tabManager.selectedTab,
                  selectedTab.canGoBack
            else { return }
            tabManager.selectedTab?.goBack()
        case .goForward:
            guard let selectedTab = tabManager.selectedTab,
                  selectedTab.canGoForward
            else { return }
            tabManager.selectedTab?.goForward()
        case .share:
            // TODO: Add this
            return
        case .bookmarks:
            // TODO: Add this
            return
        case .tabOverview:
            // TODO: Add this
            return
        default:
            logger.critical("""
            Invalid button operation \(buttonItem.operation.rawValue) for toolbar state \(tabToolbar.state!)
            """)
            return
        }
    }

    func gridTabsToolbar(_ tabToolbar: TabToolbar, didPress buttonItem: TabToolbarButtonItem) {
        switch buttonItem.operation {
        case .addTab:
            let newTab = tabManager.addTab(with: nil, after: nil)
            tabManager.selectTab(newTab)
        case .tabGroups:
            // TODO: Add this
            return
        case .focusSelectedTab:
            // TODO: Add this
            return
        default:
            logger.critical("""
            Invalid button operation \(buttonItem.operation.rawValue) for toolbar state \(tabToolbar.state!)
            """)
            return
        }
    }
}

// MARK: - URLBarDelegate

extension BrowserViewController: URLBarDelegate {

    func urlBar(_ urlBar: URLBar, didPan panGestureRecognizer: UIPanGestureRecognizer) {
        let transition = panGestureRecognizer.translation(in: view)

        switch panGestureRecognizer.state {
        case .began:
            logger.info("url bar pan gesture began")
            if transition.y != 0 {
                urlBar.previousURLTextField.isHidden = true
                urlBar.nextURLTextField.isHidden = true
            }
        case .changed:
            logger.info("url bar pan gesture changed: transition.x: \(transition.x) .y: \(transition.y)")
            UIView.animate(withDuration: 0, delay: 0) { [self] in
                let transitionY = transition.y
                if transitionY < 0 {
                    let zoomOutRatio = max(1 + (transition.y * 2) / UIScreen.main.bounds.height, 0.5)
                    urlBar.transform = CGAffineTransform(translationX: transition.x, y: transitionY)
                        .scaledBy(x: zoomOutRatio, y: zoomOutRatio)
                    tabContainer.transform = CGAffineTransform(translationX: transition.x, y: 0)
                        .scaledBy(x: zoomOutRatio, y: zoomOutRatio)
                    if transitionY < UIConstants.URLBarHiddenTy,
                       !urlBar.isHidden {
                        urlBar.isHidden = true
                    }
                    if transitionY >= UIConstants.URLBarHiddenTy,
                       urlBar.isHidden {
                        urlBar.isHidden = false
                    }
                } else {
                    urlBar.transform = CGAffineTransform(translationX: transition.x, y: 0)
                    tabContainer.transform = CGAffineTransform(translationX: transition.x, y: 0)
                }
            }
        case .ended:
            logger.info("url bar pan gesture ended")
            UIView.animate(withDuration: 0.2, delay: 0) { [self] in
                urlBar.transform = .identity
                tabContainer.transform = .identity
            }
            urlBar.updateURLTextFields()
        default:
            break
        }
    }
}

// MARK: - WKUIDelegate

extension BrowserViewController: WKUIDelegate {

}
