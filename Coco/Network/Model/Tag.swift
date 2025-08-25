//
//  Tag.swift
//  Coco
//
//  Created by Azmi on 18/08/25.
//

import Foundation

// MARK: - FirebaseData
struct FirebaseData: Codable {
    let tag: [Tag]
    let tagActivities: [TagActivity]
    let tagCategory: [TagCategory]

    enum CodingKeys: String, CodingKey {
        case tag
        case tagActivities = "tag_activities"
        case tagCategory = "tag_category"
    }
}


// MARK: - Tag
struct Tag: Codable, Identifiable {
    let id: Int?
    let name: String
    let tagCategoryID: Int?

    enum CodingKeys: String, CodingKey {
        case id, name
        case tagCategoryID = "tag_category_id"
    }
}

// MARK: - TagActivity
struct TagActivity: Codable, Identifiable {
    let id, activityID, tagID: Int

    enum CodingKeys: String, CodingKey {
        case id
        case activityID = "activity_id"
        case tagID = "tag_id"
    }
}

// MARK: - TagCategory
struct TagCategory: Codable, Identifiable {
    let id: Int
    let name: String
}
