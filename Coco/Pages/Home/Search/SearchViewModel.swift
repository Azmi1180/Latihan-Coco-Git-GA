
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
    
    weak var delegate: SearchViewModelDelegate?
    
    init(
        searchBarViewModel: HomeSearchBarViewModel,
        latestSearches: [HomeSearchSearchLocationData] = [],
        activityFetcher: ActivityFetcherProtocol = ActivityFetcher(),
    ) {
        self.searchBarViewModel = searchBarViewModel
        self.activityFetcher = activityFetcher
        self.latestSearches = latestSearches
    }
    
    @MainActor
    func onAppear() {
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
        delegate?.searchViewModel(didApplySearch: query)
    }

    func removeLatestSearch(at index: Int) {
        latestSearches.remove(at: index)
    }
}

