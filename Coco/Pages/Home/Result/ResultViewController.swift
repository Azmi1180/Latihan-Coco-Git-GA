
//
//  ResultViewController.swift
//  Coco
//
//  Created by Reynard on 25/08/25.
//

import Foundation
import UIKit
import SwiftUI

class ResultViewController: UIViewController, HomeCollectionViewModelDelegate {
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
        thisView.hideEmptyStateView()
        viewModel.delegate = self
        let collectionViewController = HomeCollectionViewController(viewModel: viewModel)
        addChild(collectionViewController)
        thisView.addSearchResultView(from: collectionViewController.view)
        collectionViewController.didMove(toParent: self)
    }


    // MARK: - HomeCollectionViewModelDelegate
    func notifyCollectionViewActivityDidTap(_ dataModel: HomeActivityCellDataModel) {
        // Find the corresponding Activity using the id
        guard let navigationController = self.navigationController else { return }
        // You need access to activities array, so cast viewModel to ResultViewModel
        guard let resultVM = viewModel as? ResultViewModel else { return }
        guard let activity = resultVM.activities.first(where: { $0.id == dataModel.id }) else { return }
        let detailData = ActivityDetailDataModel(activity)
        let coordinator = HomeCoordinator(
            input: .init(
                navigationController: navigationController,
                flow: .activityDetail(data: detailData)
            )
        )
        coordinator.parentCoordinator = AppCoordinator.shared
        coordinator.start()
    }
    
    func constructNavBar(viewModel: HomeSearchBarViewModel) {
        let searchBarViewController = HomeSearchBarHostingController(viewModel: viewModel)
        addChild(searchBarViewController)
        thisView.addSearchBarView(from: searchBarViewController.view)
        searchBarViewController.didMove(toParent: self)
    }
    
    func notifySearchBarTappedForNavigation() {
        navigationController?.popViewController(animated: true)
    }
    
    func openFilterTray(_ viewModel: HomeSearchFilterTrayViewModel) {
        presentTray(view: HomeSearchFilterTray(viewModel: viewModel))
    }

    func dismissTray() {
        dismiss(animated: true)
    }
    
    func constructFilterPills(pills: [FilterPillDataModel], selectedPillId: String?, delegate: FilterPillViewDelegate) {
        let filterPillView = FilterPillView()
        filterPillView.configure(with: pills, selectedPillId: selectedPillId)
        filterPillView.delegate = delegate
        
        thisView.addFilterPillsView(from: filterPillView)
    }
    
    func showEmptyState() {
        thisView.showEmptyStateView()
    }
}

private extension ResultViewController {
    func presentTray(view: some View) {
        let trayVC: UIHostingController = UIHostingController(rootView: view)
        if let sheet: UISheetPresentationController = trayVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = 0
        }
        present(trayVC, animated: true)
    }
}

