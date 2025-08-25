//
//  HomeActivityCellDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation

struct HomeActivityCellDataModel: Hashable {
    let id: Int

    let area: String
    let name: String
    let priceText: String
    let imageUrl: URL?
    let isFamilyFriendly: Bool

    init(id: Int, area: String, name: String, priceText: String, imageUrl: URL?, isFamilyFriendly: Bool) {
        self.id = id
        self.area = area
        self.name = name
        self.priceText = priceText
        self.imageUrl = imageUrl
        self.isFamilyFriendly = isFamilyFriendly
    }

    init(activity: Activity) {
        self.id = activity.id
        self.name = activity.title
        self.area = activity.destination.name
        self.priceText = "\(activity.pricing)"
        self.imageUrl = if let thumbnail = activity.images.first(where: { $0.imageType == .thumbnail })?.imageUrl {
            URL(string: thumbnail)
        } else {
            nil
        }
        self.isFamilyFriendly = activity.isFamilyTopPick
    }
}

typealias HomeActivityCellSectionDataModel = (title: String?, dataModel: [HomeActivityCellDataModel])
