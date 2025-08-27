
protocol SearchViewModelDelegate: AnyObject {
    func searchViewModel(didApplySearch query: String)
}

//
//  SearchViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 08/07/25.
//

import Foundation
import SwiftUI

struct HomeSearchSearchLocationData {
    let id: Int
    let name: String
}

final class SearchViewModel: ObservableObject {
    @Published var searchBarViewModel: HomeSearchBarViewModel
    @Published var popularLocations: [HomeSearchSearchLocationData] = []
    @Published var latestSearches: [HomeSearchSearchLocationData]
    @Published var lastSearchQuery: String?
    
    weak var delegate: SearchViewModelDelegate?
    
    init(
        searchBarViewModel: HomeSearchBarViewModel,
        latestSearches: [HomeSearchSearchLocationData] = [],
        activityFetcher: ActivityFetcherProtocol = ActivityFetcher(),
        lastSearchQuery: String? = nil
    ) {
        self.searchBarViewModel = searchBarViewModel
        self.activityFetcher = activityFetcher
        self.latestSearches = latestSearches
        self.lastSearchQuery = lastSearchQuery
        if let lastSearchQuery = lastSearchQuery {
            self.searchBarViewModel.currentTypedText = lastSearchQuery
        }
    }
    
    @MainActor
    func onAppear() {
        searchBarViewModel.isSearchBarFocused = true
        activityFetcher.fetchTopDestination() { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.popularLocations = response.values.map {
                    return HomeSearchSearchLocationData(id: $0.id, name: $0.name)
                }
            case .failure(let failure):
                break
            }
        }
    }
    
    private let activityFetcher: ActivityFetcherProtocol

    func applySearch(query: String) {
        self.lastSearchQuery = query
        delegate?.searchViewModel(didApplySearch: query)
    }

    func removeLatestSearch(at index: Int) {
        latestSearches.remove(at: index)
    }
}

