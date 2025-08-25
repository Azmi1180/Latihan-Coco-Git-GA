
//
//  ResultCoordinator.swift
//  Coco
//
//  Created by Reynard on 25/08/25.
//

import Foundation
import UIKit

class ResultCoordinator: BaseCoordinator {
    let searchResults: [HomeActivityCellDataModel]
    let query: String
    
    init(navigationController: UINavigationController, searchResults: [HomeActivityCellDataModel], query: String) {
        self.searchResults = searchResults
        self.query = query
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        guard let navigationController = navigationController else { return }
        let viewModel = ResultViewModel(searchResults: searchResults, query: query)
        let viewController = ResultViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
