
//
//  ResultViewModel.swift
//  Coco
//
//  Created by Reynard on 25/08/25.
//

import Foundation

class ResultViewModel: ResultViewModelProtocol {
    weak var actionDelegate: ResultViewModelAction?
    
    private let searchResults: [HomeActivityCellDataModel]
    private let query: String
    
    init(searchResults: [HomeActivityCellDataModel], query: String) {
        self.searchResults = searchResults
        self.query = query
    }
    
    func onViewDidLoad() {
        let collectionViewModel = HomeCollectionViewModel()
        collectionViewModel.updateActivity(sections: [
            HomeSectionData(sectionType: .activity, sectionDataModel: HomeActivityCellSectionDataModel(title: "", dataModel: searchResults))
        ])
        actionDelegate?.constructCollectionView(viewModel: collectionViewModel)
        
        let searchBarViewModel = HomeSearchBarViewModel(
            leadingIcon: CocoIcon.icSearchLoop.image,
            placeholderText: "Search...",
            currentTypedText: query,
            trailingIcon: (image: CocoIcon.icFilterIcon.image, didTap: {}),
            isTypeAble: false,
            delegate: self
        )
        actionDelegate?.constructNavBar(viewModel: searchBarViewModel)
    }
}

extension ResultViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        // Not used for this specific case
    }
    
    func homeSearchBarDidTapForNavigation() {
        actionDelegate?.notifySearchBarTappedForNavigation()
    }
}
