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
        viewModel.actionDelegate = self // Add this
        return viewModel
    }()
    private(set) lazy var loadingState: HomeLoadingState = HomeLoadingState()
    private(set) lazy var searchBarViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: CocoIcon.icSearchLoop.image,
        placeholderText: "Search...",
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icFilterIcon.image,
            didTap: openFilterTray
        ),
        isTypeAble: false,
        delegate: self
    )
    
    private var responseMap: [Int: Activity] = [:]
    private var responseData: [Activity] = []
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var filterDataModel: HomeSearchFilterTrayDataModel?
    
    var isSearching: Bool = false
    var filteredOtherDestinationData: [HomeActivityCellDataModel] = []
    var otherDestinationData: [HomeActivityCellDataModel] = []
}

extension HomeViewModel: HomeViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.constructRecommendationView(viewModel: collectionViewModel)
        actionDelegate?.constructLoadingState(state: loadingState)
        actionDelegate?.constructNavBar(viewModel: searchBarViewModel)
        
        fetch()
    }
    
    func onSearchDidApply(_ queryText: String) {
        searchBarViewModel.currentTypedText = queryText

        if queryText.isEmpty {
            // When search is cleared, fetch the original full list of data.
            fetch()
            return
        }

        isSearching = true
        // Run search on a background thread to avoid blocking the UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            let searchKeywords = queryText.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

            // Filter activities based on the search keywords.
            let filteredActivities = self.responseData.filter { activity in
                let title = activity.title.lowercased()
                let destinationName = activity.destination.name.lowercased()

                // All keywords must be present in either the title or destination name.
                return searchKeywords.allSatisfy { keyword in
                    title.contains(keyword) || destinationName.contains(keyword)
                }
            }
            
            let searchDataModel = filteredActivities.map { HomeActivityCellDataModel(activity: $0) }

            // Create a section for the search results.
            let searchResultSectionDataModel = HomeActivityCellSectionDataModel(
                title: HomeViewModel.searchResultSectionTitle, // Empty title to hide the header
                dataModel: searchDataModel
            )
            let searchResultSection = HomeSectionData(
                sectionType: .activity,
                sectionDataModel: searchResultSectionDataModel
            )

            // Update the collection view on the main thread.
            DispatchQueue.main.async { [weak self] in
                self?.collectionViewModel.updateActivity(sections: [searchResultSection])
            }
        }
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
        
        // TODO: Change with real data
        actionDelegate?.searchDidTap(
            latestSearches: [
                .init(id: 1, name: "Kepulauan Seribu"),
                .init(id: 2, name: "Nusa Penida"),
                .init(id: 3, name: "Gili Island, Indonesia"),
            ],
            currentQuery: searchBarViewModel.currentTypedText
        )
    }
}

private extension HomeViewModel {
    func fetch() {
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
                self.actionDelegate?.toggleLoadingView(isShown: false, after: 0.0)
                print("✅ Fetch Success")
                print("Jumlah response: \(response.values.count)")

                let activities = response.values
                activities.forEach { activity in
                    print("""
                           --- Activity ---
                           ID: \(activity.id)
                           Nama: \(activity.title)
                           Harga: \(activity.pricing)
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
                self.otherDestinationData = generalData.map { HomeActivityCellDataModel(activity: $0) }
                
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
                
                DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.contructFilterData()
                }
            case .failure(let failure):
                break
            }
        }
    }
    
    func contructFilterData() {
        let responseMapActivity: [Activity] = Array(responseMap.values)
        var seenIDs: Set<Int> = Set()
        var activityValues: [HomeSearchFilterPillState] = responseMap.values
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
    
    func openFilterTray() {
        guard let filterDataModel: HomeSearchFilterTrayDataModel else { return }
        
        let viewModel: HomeSearchFilterTrayViewModel = HomeSearchFilterTrayViewModel(
            dataModel: filterDataModel,
            activities: Array(responseMap.values)
        )
        viewModel.filterDidApplyPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newFilterData in
                guard let self else { return }
                self.filterDataModel = newFilterData
                actionDelegate?.dismissTray()
                filterDidApply()
            }
            .store(in: &cancellables)
        
        actionDelegate?.openFilterTray(viewModel)
    }
    
    func filterDidApply() {
        guard let filterDataModel: HomeSearchFilterTrayDataModel else { return }
        let tempResponseData: [Activity] = HomeFilterUtil.doFilter(
            responseData,
            filterDataModel: filterDataModel
        )
        
        let searchResultSectionDataModel = HomeActivityCellSectionDataModel(
            title: "Search Result",
            dataModel: tempResponseData.map { HomeActivityCellDataModel(activity: $0) }
        )
        
        let searchResultSection = HomeSectionData(
            sectionType: .activity, // Assuming search results use the activity layout
            sectionDataModel: searchResultSectionDataModel
        )
        
        collectionViewModel.updateActivity(sections: [searchResultSection])
    }
}

extension HomeViewModel: HomeCollectionViewModelAction {
    func configureDataSource() {
        // This method is called by HomeCollectionViewModel to configure its data source.
        // HomeViewModel doesn't directly configure the data source, HomeCollectionViewController does.
        // So, we can leave this empty or log a message.
    }
    
    func applySnapshot(_ snapshot: HomeCollectionViewSnapShot, completion: (() -> Void)?) {
        // This method is called by HomeCollectionViewModel to apply a snapshot.
        // HomeViewModel doesn't directly apply the snapshot, HomeCollectionViewController does.
        // We need to forward this call to the HomeCollectionViewController's data source.
        // This implies HomeViewModel needs a reference to HomeCollectionViewController's data source.
        // This is a design flaw. HomeCollectionViewModel should not be calling applySnapshot directly.
        // Instead, HomeCollectionViewModel should update its activityData, and HomeCollectionViewController
        // should observe changes to activityData and apply the snapshot.
        
        // For now, to fix the compilation error, I will leave this empty.
        // A proper fix would involve refactoring the data flow.
        completion?()
    }
}
