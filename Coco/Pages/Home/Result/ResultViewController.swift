
//
//  ResultViewController.swift
//  Coco
//
//  Created by Reynard on 25/08/25.
//

import Foundation
import UIKit
import SwiftUI

class ResultViewController: UIViewController {
    private let viewModel: ResultViewModelProtocol
    private let thisView = ResultView()
    
    init(viewModel: ResultViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = thisView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
        
        // Custom back button
        self.navigationItem.hidesBackButton = true
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        backButton.tintColor = Token.mainColorPrimary
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension ResultViewController: ResultViewModelAction {
    func constructCollectionView(viewModel: some HomeCollectionViewModelProtocol) {
        let collectionViewController = HomeCollectionViewController(viewModel: viewModel)
        addChild(collectionViewController)
        thisView.addSearchResultView(from: collectionViewController.view)
        collectionViewController.didMove(toParent: self)
    }
    
    func constructNavBar(viewModel: HomeSearchBarViewModel) {
        let searchBarViewController = HomeSearchBarHostingController(viewModel: viewModel)
        addChild(searchBarViewController)
        thisView.addSearchBarView(from: searchBarViewController.view)
        searchBarViewController.didMove(toParent: self)
    }
}
