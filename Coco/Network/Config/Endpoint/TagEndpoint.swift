//
//  TagEndpoint.swift
//  Coco
//
//  Created by Azmi on 18/08/25.
//

import Foundation

enum TagEndpoint {
    case getAllData
}

extension TagEndpoint: EndpointProtocol {
    var source: APISource {
        return .firebase
    }
    
    var path: String {
        switch self {
        case .getAllData:
            return ".json"
        }
    }
}
