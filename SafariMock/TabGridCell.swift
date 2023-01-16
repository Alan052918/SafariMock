//
//  TabGridCell.swift
//  SafariMock
//
//  Created by Junda Ai on 11/21/22.
//

import UIKit

class TabGridCell: UICollectionViewCell {

    lazy var closeButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}
