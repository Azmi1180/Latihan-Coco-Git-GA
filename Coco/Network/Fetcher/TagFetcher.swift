//
//  TagFetcher.swift
//  Coco
//
//  Created by Azmi on 26/08/25.
//

import Foundation

protocol TagFetcherProtocol {
    func fetchFirebaseData() async throws -> FirebaseData
}

final class TagFetcher: TagFetcherProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchFirebaseData() async throws -> FirebaseData {
        let endpoint = TagEndpoint.getAllData
        return try await networkService.request(
            urlString: endpoint.urlString,
            method: .get,
            parameters: [:],
            headers: [:],
            body: nil
        )
    }
}
