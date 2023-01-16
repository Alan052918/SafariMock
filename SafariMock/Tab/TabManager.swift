//  TabManager.swift
//  SafariMock
//
//  Created by Junda Ai on 11/20/22.
//

import Logging
import WebKit

protocol TabManagerProtocol {
    var tabs: [Tab] { get }
    var selectedTab: Tab? { get }
    var previousOfSelectedTab: Tab? { get }
    var nextOfSelectedTab: Tab? { get }

    func selectTab(_ tab: Tab?)
    func addTab(with request: URLRequest?, after parentTab: Tab?) -> Tab
}

protocol TabManagerDelegate: AnyObject {
    func tabManager(_ tabManager: TabManagerProtocol, didSelect tab: Tab, after previousTab: Tab?)
    func tabManager(_ tabManager: TabManagerProtocol, didAdd tab: Tab, after previousTab: Tab?)
}

class TabManager: NSObject, TabManagerProtocol {

    private(set) var tabs = [Tab(configuration: WKWebViewConfiguration())]
    var tabCount: Int {
        return tabs.count
    }

    private var _selectedIndex = 0
    var selectedIndex: Int {
        return _selectedIndex
    }
    var selectedTab: Tab? {
        guard (0..<tabCount).contains(_selectedIndex) else { return nil }
        return tabs[_selectedIndex]
    }
    var previousOfSelectedTab: Tab? {
        guard tabCount > 0,
              (1..<tabCount).contains(_selectedIndex)
        else { return nil }
        return tabs[_selectedIndex - 1]
    }
    var nextOfSelectedTab: Tab? {
        guard tabCount > 0,
              (0..<(tabCount - 1)).contains(_selectedIndex)
        else { return nil }
        return tabs[_selectedIndex + 1]
    }

    private let logger = Logger(label: "TabManager")

    // MARK: - TabManagerProtocol

    func selectTab(_ tab: Tab?) {
        guard let tab = tab,
              let selectIndex = tabs.firstIndex(of: tab)
        else {
            _selectedIndex = -1
            return
        }
        _selectedIndex = selectIndex
        selectedTab?.createWebView()
    }

    func addTab(with request: URLRequest?, after previousTab: Tab?) -> Tab {
        let configuration = WKWebViewConfiguration()
        let tab = Tab(configuration: configuration)
        configureTab(tab, with: request, after: previousTab)
        return tab
    }

    func configureTab(_ tab: Tab, with request: URLRequest?, after previousTab: Tab?) {
        tab.url = request?.url
        tab.navigationDelegate = self

        if let request = request {
            tab.load(request)
        }
    }
}

extension TabManager: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }
}
