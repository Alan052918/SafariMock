//
//  Tab.swift
//  SafariMock
//
//  Created by Junda Ai on 11/20/22.
//

import WebKit

protocol TabDelegate: AnyObject {
    func tab(_ tab: Tab, didCreateWebView webView: WKWebView)
    func tab(_ tab: Tab, willDeleteWebView webView: WKWebView)
}

class Tab: NSObject {

    weak var delegate: TabDelegate!

    var url: URL?

    var webView: WKWebView?
    let configuration: WKWebViewConfiguration
    weak var navigationDelegate: WKNavigationDelegate? {
        didSet {
            if let webView = webView {
                webView.navigationDelegate = navigationDelegate
            }
        }
    }

    var title: String? {
        guard let title = webView?.title,
              !title.isEmpty
        else { return nil }
        return title
    }
    var isLoading: Bool {
        return webView?.isLoading ?? false
    }
    var estimatedProgress: Double {
        return webView?.estimatedProgress ?? 0
    }

    var canGoBack: Bool {
        return webView?.canGoBack ?? false
    }
    var canGoForward: Bool {
        return webView?.canGoForward ?? false
    }

    var homepageViewController = HomepageViewController(nibName: nil, bundle: nil)

    init(configuration: WKWebViewConfiguration) {
        self.configuration = configuration
    }

    func createWebView() {
        guard webView == nil else { return }

        let webView = WKWebView()
        webView.backgroundColor = .clear
//        webView.scrollView.layer.masksToBounds = false
        webView.navigationDelegate = navigationDelegate
        self.webView = webView

        configureEdgePanGestureRecognizer()
        delegate?.tab(self, didCreateWebView: webView)
    }

    func close() {
        guard let webView = webView else { return }

        delegate?.tab(self, willDeleteWebView: webView)
        webView.navigationDelegate = nil
        webView.removeFromSuperview()
        self.webView = nil
    }

    // MARK: - WebView Navigation

    @discardableResult
    func load(_ request: URLRequest) -> WKNavigation? {
        guard let webView = webView else { return nil }
        return webView.load(request)
    }

    func stop() {
        webView?.stopLoading()
    }

    @discardableResult
    func reload() -> WKNavigation? {
        return webView?.reload()
    }

    @discardableResult
    func goBack() -> WKNavigation? {
        return webView?.goBack()
    }

    @discardableResult
    func goForward() -> WKNavigation? {
        return webView?.goForward()
    }

    @discardableResult
    func goToBackForwardListItem(_ item: WKBackForwardListItem) -> WKNavigation? {
        return webView?.go(to: item)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension Tab: UIGestureRecognizerDelegate {

    func configureEdgePanGestureRecognizer() {

    }
}
