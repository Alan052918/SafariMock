//
//  TabGridViewController.swift
//  SafariMock
//
//  Created by Junda Ai on 11/20/22.
//

import UIKit

class TabsGridViewController: UIViewController {

    let tabManager: TabManager
    var collectionView: UICollectionView!

    init(tabManager: TabManager) {
        self.tabManager = tabManager

        super.init(nibName: nil, bundle: nil)

        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TabsGridCell.self, forCellWithReuseIdentifier: String(describing: TabsGridCell.self))
        self.collectionView = collectionView
    }
}
