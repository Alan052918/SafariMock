//
//  TabToolbar.swift
//  SafariMock
//
//  Created by Junda Ai on 11/21/22.
//

import Logging
import UIKit

protocol TabToolbarDelegate: AnyObject {
    func tabToolbar(_ tabToolbar: TabToolbar, didPress buttonItem: TabToolbarButtonItem)
}

class TabToolbar: UIToolbar {

    enum State: String {
        case selectedTab
        case tabsGrid
    }
    var state: State! {
        didSet {
            switch state {
            case .selectedTab:
                setItems(selectedTabButtonItems, animated: true)
            case .tabsGrid:
                setItems(gridTabsButtonItems, animated: true)
            default:
                logger.critical("Invalid TabToolbar.State \(String(describing: state))")
            }
        }
    }

    weak var tabToolbarDelegate: TabToolbarDelegate!

    private var backButtonItem: TabToolbarButtonItem!
    private var forwardButtonItem: TabToolbarButtonItem!
    private var shareButtonItem: TabToolbarButtonItem!
    private var bookmarksButtonItem: TabToolbarButtonItem!
    private var tabOverviewButtonItem: TabToolbarButtonItem!
    private var selectedTabButtonItems: [UIBarButtonItem]!

    private var addTabButtonItem: TabToolbarButtonItem!
    private var tabGroupsButtonItem: TabToolbarButtonItem!
    private var doneButtonItem: TabToolbarButtonItem!
    private var gridTabsButtonItems: [UIBarButtonItem]!

    private let logger = Logger(label: "TabToolbar")

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init() {
        self.init(frame: CGRect(x: 0,
                                y: 0,
                                width: UIScreen.main.bounds.width,
                                height: UIConstants.TabToolbarExtendedHeight))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        UIView.setAnimationsEnabled(true)

        defer {
            state = .selectedTab
        }
        setupSubviews()
    }

    func setupSubviews() {
        // TabToolbar.State.selectedTab
        backButtonItem = TabToolbarButtonItem()
        backButtonItem.operation = .goBack
        backButtonItem.image = UIImage(systemName: "chevron.backward")
        backButtonItem.target = self
        backButtonItem.action = #selector(pressButtonItem(_:))

        forwardButtonItem = TabToolbarButtonItem()
        forwardButtonItem.operation = .goForward
        forwardButtonItem.image = UIImage(systemName: "chevron.forward")
        forwardButtonItem.target = self
        forwardButtonItem.action = #selector(pressButtonItem(_:))

        shareButtonItem = TabToolbarButtonItem()
        shareButtonItem.operation = .share
        shareButtonItem.image = UIImage(systemName: "square.and.arrow.up")
        shareButtonItem.target = self
        shareButtonItem.action = #selector(pressButtonItem(_:))

        bookmarksButtonItem = TabToolbarButtonItem(barButtonSystemItem: .bookmarks,
                                                   target: self,
                                                   action: #selector(pressButtonItem(_:)))
        bookmarksButtonItem.operation = .bookmarks

        tabOverviewButtonItem = TabToolbarButtonItem()
        tabOverviewButtonItem.operation = .tabOverview
        tabOverviewButtonItem.image = UIImage(systemName: "square.on.square")
        tabOverviewButtonItem.target = self
        tabOverviewButtonItem.action = #selector(pressButtonItem(_:))

        let flexibleSpace = UIBarButtonItem.flexibleSpace()
        selectedTabButtonItems = [backButtonItem, flexibleSpace,
                                  forwardButtonItem, flexibleSpace,
                                  shareButtonItem, flexibleSpace,
                                  bookmarksButtonItem, flexibleSpace,
                                  tabOverviewButtonItem]

        // TabToolbar.State.gridTabs
        addTabButtonItem = TabToolbarButtonItem(barButtonSystemItem: .add,
                                                target: self,
                                                action: #selector(pressButtonItem(_:)))
        addTabButtonItem.operation = .addTab

        tabGroupsButtonItem = TabToolbarButtonItem()
        tabGroupsButtonItem.operation = .tabGroups
        tabGroupsButtonItem.title = "Tab Groups"
        tabGroupsButtonItem.target = self
        tabGroupsButtonItem.action = #selector(pressButtonItem(_:))

        doneButtonItem = TabToolbarButtonItem(barButtonSystemItem: .done,
                                              target: self,
                                              action: #selector(pressButtonItem(_:)))
        doneButtonItem.operation = .focusSelectedTab

        gridTabsButtonItems = [addTabButtonItem, flexibleSpace, tabGroupsButtonItem, flexibleSpace, doneButtonItem]
    }

    @objc
    func pressButtonItem(_ buttonItem: TabToolbarButtonItem) {
        logger.info("press button item \(buttonItem.debugDescription)")
        tabToolbarDelegate?.tabToolbar(self, didPress: buttonItem)
    }

    func updateButtonItemState(canGoBack: Bool) {
        backButtonItem.isEnabled = canGoBack
    }

    func updateButtonItemState(canGoForward: Bool) {
        forwardButtonItem.isEnabled = canGoForward
    }

    func updateButtonItemState(canShare: Bool) {
        shareButtonItem.isEnabled = canShare
    }
}
