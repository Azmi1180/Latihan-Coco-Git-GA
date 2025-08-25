//
//  ActivityEndpoint.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/07/25.
//

import Foundation

enum ActivityEndpoint: EndpointProtocol {
    case all
    case topDestination
    case getAllActivities

    var source: APISource {
        return .supabase
    }
    
    var path: String {
        switch self {
        case .all:
            return "rpc/search_detailed_activities"
        case .topDestination:
            return "rpc/get_top_destinations"
        case .getAllActivities:
            return "activities?select=*"
        }
    }

}


