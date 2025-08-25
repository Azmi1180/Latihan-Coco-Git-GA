//
//  APIConfig.swift
//  Coco
//
//  Created by Jackie Leonardy on 30/06/25.
//

import Foundation

enum APISource {
    case supabase
    case firebase
}

enum APIConfig {
    static func baseURL(for source: APISource) -> String {
        switch source {
        case .supabase:
            return "https://guffnieowbgkilwcjkks.supabase.co/rest/v1/"
        case .firebase:
            return "https://cococo-d3c4b-default-rtdb.asia-southeast1.firebasedatabase.app/"
        }
    }
}

protocol EndpointProtocol {
    var source: APISource { get }
    var path: String { get }
    var urlString: String { get }
    var url: URL? { get }
}

extension EndpointProtocol {
    var urlString: String {
        return APIConfig.baseURL(for: source) + path
    }

    var url: URL? {
        return URL(string: urlString)
    }
}
