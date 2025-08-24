
//
//  HomeCoordinator.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/07/25.
//

import Foundation
import UIKit

final class HomeCoordinator: BaseCoordinator {
    struct Input {
        let navigationController: UINavigationController
        let flow: Flow

        enum Flow {
            case activityDetail(data: ActivityDetailDataModel)
            case search(viewModel: HomeViewModelProtocol)
        }
    }

    init(input: Input) {
        self.input = input
        if case .search(let viewModel) = input.flow {
            self.homeViewModel = viewModel
        } else {
            self.homeViewModel = nil
        }
        super.init(navigationController: input.navigationController)
    }

    override func start() {
        super.start()

        switch input.flow {
        case .activityDetail(let data):
            let detailViewModel: ActivityDetailViewModel = ActivityDetailViewModel(
                data: data
            )
            detailViewModel.navigationDelegate = self
            let detailViewController: ActivityDetailViewController = ActivityDetailViewController(viewModel: detailViewModel)
            start(viewController: detailViewController)

        case .search:
            let searchViewModel: SearchViewModel = SearchViewModel(
                searchBarViewModel: HomeSearchBarViewModel(
                    leadingIcon: CocoIcon.icSearchLoop.image,
                    placeholderText: "Search...",
                    currentTypedText: "",
                    trailingIcon: nil,
                    isTypeAble: true,
                    delegate: nil
                )
            )
            searchViewModel.delegate = self
            let searchViewController: SearchViewController = SearchViewController(viewModel: searchViewModel)
            start(viewController: searchViewController)
        }
    }

    private let input: Input
    private let homeViewModel: HomeViewModelProtocol?
}

extension HomeCoordinator: HomeViewModelNavigationDelegate {
    func notifyHomeDidSelectActivity() {
        
    }
}

extension HomeCoordinator: HomeFormScheduleViewModelDelegate {
    func notifyFormScheduleDidNavigateToCheckout(with response: CreateBookingResponse) {
        let viewModel: CheckoutViewModel = CheckoutViewModel(
            bookingResponse: response.bookingDetails
        )
        viewModel.delegate = self
        let viewController = CheckoutViewController(viewModel: viewModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.start(viewController: viewController)
        }
    }
}

extension HomeCoordinator: CheckoutViewModelDelegate {
    func notifyUserDidCheckout() {
        guard let tabBarController: BaseTabBarViewController = parentCoordinator?.navigationController?.tabBarController as? BaseTabBarViewController
        else {
            return
        }
        tabBarController.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)
    }
}

extension HomeCoordinator: ActivityDetailNavigationDelegate {
    func notifyActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int) {
        let viewModel: HomeFormScheduleViewModel = HomeFormScheduleViewModel(
            input: HomeFormScheduleViewModelInput(
                package: package,
                selectedPackageId: selectedPackageId
            )
        )
        viewModel.delegate = self
        let viewController: HomeFormScheduleViewController = HomeFormScheduleViewController(viewModel: viewModel)
        start(viewController: viewController)
    }
}

extension HomeCoordinator: SearchViewModelDelegate {
    func searchViewModel(didApplySearch query: String) {
        homeViewModel?.onSearchDidApply(query)
        navigationController?.popViewController(animated: true)
    }
}
