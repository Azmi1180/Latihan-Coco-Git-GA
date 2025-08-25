//
//  HomeViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Combine
import Foundation

final class HomeViewModel {
    
    static let topDestinationTitle = "Top Destination"
    static let topFamilyPickTitle = "Top Family Pick"
    static let otherDestinationTitle = "Other Destination"
    static let searchResultSectionTitle = "" // Special title to hide header
    weak var actionDelegate: (any HomeViewModelAction)?
    weak var navigationDelegate: (any HomeViewModelNavigationDelegate)?
    
    init(activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.activityFetcher = activityFetcher
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    private let activityFetcher: ActivityFetcherProtocol
    private(set) lazy var collectionViewModel: any HomeCollectionViewModelProtocol = {
        let viewModel: HomeCollectionViewModel = HomeCollectionViewModel()
        viewModel.delegate = self
        
        return viewModel
    }()
    private(set) lazy var loadingState: HomeLoadingState = HomeLoadingState()
    private(set) lazy var searchBarViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: CocoIcon.icSearchLoop.image,
        placeholderText: "Search...",
        currentTypedText: "",
        trailingIcon: nil,
        isTypeAble: false,
        delegate: self
    )
    
    private var responseMap: [Int: Activity] = [:]
    private var responseData: [Activity] = []
    private var allActivities: [Activity] = []
    private var cancellables: Set<AnyCancellable> = Set()
    
    var isSearching: Bool = false
    var filteredOtherDestinationData: [HomeActivityCellDataModel] = []
    var otherDestinationData: [HomeActivityCellDataModel] = []
    var searchedTopDestinationData: [HomeActivityCellDataModel] = []
    var searchedTopFamilyPickData: [HomeActivityCellDataModel] = []
    var searchedAllData: [HomeActivityCellDataModel] = []
    
    private func fetch() {
        loadingState.percentage = 0
        isSearching = false
        filteredOtherDestinationData = []
        if !searchBarViewModel.currentTypedText.isEmpty {
            // The search is handled in onSearchDidApply, so we don't need to do anything here.
            return
        }
        
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: "")
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                var sections: [HomeSectionData] = []
                self.loadingState.percentage = 100
                self.actionDelegate?.toggleLoadingView(isShown: false, after: 0)
                print("✅ Fetch Success")
                print("Jumlah response: \(response.values.count)")
                
                var activities = response.values
                for index in 0..<activities.count {
                    if index < 5 {
                        activities[index].isTopDestination = true
                    } else if index < 10 {
                        activities[index].isFamilyTopPick = true
                    }
                }
                
                self.allActivities = activities
                self.searchedAllData = activities.map { HomeActivityCellDataModel(activity: $0) }
                activities.forEach { activity in
                    print("""
                       --- Activity ---
                       ID: \(activity.id)
                       Nama: \(activity.title)
                       Harga: \(activity.pricing)
                       description: \(activity.description)
                       Accessories: \(activity.accessories.map { $0.name })
                       Cancelable: \(activity.cancelable)
                       ---------------
                       """)
                    self.responseMap[activity.id] = activity
                }
                
                self.responseData = activities
                
                let topDestinationData = Array(activities.prefix(5))
                let topFamilyPickData = Array(activities.dropFirst(5).prefix(5))
                let generalData = Array(activities.dropFirst(10))
                self.otherDestinationData = generalData.map { HomeActivityCellDataModel(activity: $0) } +
                topDestinationData.map { HomeActivityCellDataModel(activity: $0) } +
                topFamilyPickData.map { HomeActivityCellDataModel(activity: $0) }
                
                if !topDestinationData.isEmpty {
                    let topDestinationSectionDataModel = HomeActivityCellSectionDataModel(
                        title: HomeViewModel.topDestinationTitle,
                        dataModel: topDestinationData.map { HomeActivityCellDataModel(activity: $0) }
                    )
                    let topDestinationSection = HomeSectionData(
                        sectionType: .popularDestination,
                        sectionDataModel: topDestinationSectionDataModel
                    )
                    sections.append(topDestinationSection)
                }
                
                if !topFamilyPickData.isEmpty {
                    let topFamilyPickSectionDataModel = HomeActivityCellSectionDataModel(
                        title: HomeViewModel.topFamilyPickTitle,
                        dataModel: topFamilyPickData.map { HomeActivityCellDataModel(activity: $0) }
                    )
                    let topFamilyPickSection = HomeSectionData(
                        sectionType: .familyTopPick,
                        sectionDataModel: topFamilyPickSectionDataModel
                    )
                    sections.append(topFamilyPickSection)
                }
                
                if !generalData.isEmpty {
                    let generalSectionDataModel = HomeActivityCellSectionDataModel(
                        title: HomeViewModel.otherDestinationTitle,
                        dataModel: generalData.map { HomeActivityCellDataModel(activity: $0) }
                    )
                    let generalSection = HomeSectionData(
                        sectionType: .activity,
                        sectionDataModel: generalSectionDataModel
                    )
                    sections.append(generalSection)
                }
                
                self.collectionViewModel.updateActivity(sections: sections)
                
            case .failure(let failure):
                break
            }
        }
    }
}

extension HomeViewModel: HomeViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.constructRecommendationView(viewModel: collectionViewModel)
        actionDelegate?.constructLoadingState(state: loadingState)
        actionDelegate?.constructNavBar(viewModel: searchBarViewModel)
        
        fetch()
    }
    
    func getActivities() -> [Activity] {
        return responseData
    }

    func onSearchDidApply(_ queryText: String) {
        searchBarViewModel.currentTypedText = queryText
    }
}

extension HomeViewModel: HomeCollectionViewModelDelegate {
    func notifyCollectionViewActivityDidTap(_ dataModel: HomeActivityCellDataModel) {
        guard let activity: Activity = responseMap[dataModel.id] else { return }
        let data: ActivityDetailDataModel = ActivityDetailDataModel(activity)
        actionDelegate?.activityDidSelect(data: data)
    }
}

extension HomeViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        guard !isTypeAble else { return }
        
        // This method is now deprecated. Use homeSearchBarDidTapForNavigation instead.
        // The logic here is moved to homeSearchBarDidTapForNavigation.
    }
    
    func homeSearchBarDidTapForNavigation() {
        actionDelegate?.navigateToSearch(
            latestSearches: [
                HomeSearchSearchLocationData(id: 1, name: "Kepulauan Seribu"),
                HomeSearchSearchLocationData(id: 2, name: "Nusa Penida"),
                HomeSearchSearchLocationData(id: 3, name: "Gili Island, Indonesia"),
            ],
            currentQuery: searchBarViewModel.currentTypedText
        )
    }
}
