
//
//  ResultViewModel.swift
//  Coco
//
//  Created by Reynard on 25/08/25.
//

import Foundation

import Combine

class ResultViewModel: ResultViewModelProtocol {
    weak var actionDelegate: ResultViewModelAction?
    
    private let searchResults: [HomeActivityCellDataModel]
    private let query: String
    private let activities: [Activity]
    
    private(set) var filterDataModel: HomeSearchFilterTrayDataModel?
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(searchResults: [HomeActivityCellDataModel], query: String, activities: [Activity]) {
        self.searchResults = searchResults
        self.query = query
        self.activities = activities
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
            trailingIcon: (image: CocoIcon.icFilterIcon.image, didTap: openFilterTray),
            isTypeAble: false,
            delegate: self
        )
        actionDelegate?.constructNavBar(viewModel: searchBarViewModel)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.contructFilterData()
        }
    }
    
    private func contructFilterData() {
        let responseMapActivity: [Activity] = activities
        var seenIDs: Set<Int> = Set()
        var activityValues: [HomeSearchFilterPillState] = responseMapActivity
            .flatMap { $0.accessories }
            .filter { accessory in
                if seenIDs.contains(accessory.id) {
                    return false
                } else {
                    seenIDs.insert(accessory.id)
                    return true
                }
            }
            .map {
                HomeSearchFilterPillState(
                    id: $0.id,
                    title: $0.name,
                    isSelected: false
                )
            }
        
        if responseMapActivity.first(where: { !$0.cancelable.isEmpty }) != nil {
            activityValues.append(
                HomeSearchFilterPillState(
                    id: -99999999,
                    title: "Free Cancellation",
                    isSelected: false
                )
            )
        }
        let sortedData = responseMapActivity.sorted { $0.pricing < $1.pricing }
        let minPrice: Double = sortedData.first?.pricing ?? 0
        let maxPrice: Double = sortedData.last?.pricing ?? 0
        let filterDataModel: HomeSearchFilterTrayDataModel = HomeSearchFilterTrayDataModel(
            filterPillDataState: activityValues,
            priceRangeModel: HomeSearchFilterPriceRangeModel(
                minPrice: minPrice,
                maxPrice: maxPrice,
                range: minPrice...maxPrice,
                step: 1
            )
        )
        
        self.filterDataModel = filterDataModel
    }
    
    private func openFilterTray() {
        guard let filterDataModel: HomeSearchFilterTrayDataModel else { return }
        
        let viewModel: HomeSearchFilterTrayViewModel = HomeSearchFilterTrayViewModel(
            dataModel: filterDataModel,
            activities: activities
        )
        viewModel.filterDidApplyPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newFilterData in
                guard let self else { return }
                self.filterDataModel = newFilterData
                actionDelegate?.dismissTray()
                // TODO: Apply filter to search results
            }
            .store(in: &cancellables)
        
        actionDelegate?.openFilterTray(viewModel)
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
