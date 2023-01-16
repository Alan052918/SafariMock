//
//  ToolbarButton.swift
//  SafariMock
//
//  Created by Junda Ai on 11/21/22.
//

import UIKit

class TabToolbarButtonItem: UIBarButtonItem {

    enum Operation: String {
        case goBack
        case goForward
        case share
        case bookmarks
        case tabOverview
        case addTab
        case tabGroups
        case focusSelectedTab
    }

    var operation: Operation!
}
