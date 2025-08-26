//
//  ActivityDetailDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation

struct ActivityDetailDataModel: Equatable {
    let title: String
    let location: String
    let imageUrlsString: [String]

    let detailInfomation: ActivitySectionLayout<String>
    let providerDetail: ActivitySectionLayout<ProviderDetail>
    let whatsIncluded: ActivitySectionLayout<WhatsIncluded>
    let moreInfo: [ActivitySectionLayout<String>]

    let availablePackages: ActivitySectionLayout<[Package]>
    let hiddenPackages: [Package]

    struct WhatsIncluded: Equatable {
        let providerAndSafety: [String]
        let equipment: [String]
        let services: [String]
        let guideLanguage: [String]
    }

    struct ProviderDetail: Equatable {
        let name: String
        let description: String
        let imageUrlString: String
    }

    struct Package: Equatable {
        let imageUrlString: String
        let name: String
        let description: String
        let price: String

        let id: Int
    }

    init(_ response: Activity) {
        title = response.title
        location = response.destination.name
        imageUrlsString = response.images
            .filter { $0.imageType != .banner }
            .map { $0.imageUrl }

        detailInfomation = ActivitySectionLayout(
            title: "Trip Overview",
            content: response.description
        )
        providerDetail = ActivitySectionLayout(
            title: "Trip Provider",
            content: ProviderDetail(
                name: response.packages[0].host.name,
                description: response.packages[0].host.bio,
                imageUrlString: response.packages[0].host.profileImageUrl
            )
        )
        whatsIncluded = ActivitySectionLayout(
            title: "What's Included",
            content: WhatsIncluded(
                providerAndSafety: ["Verified Provider", "Certified Guide", "First Aid Ready"],
                equipment: ["All Size Available"],
                services: ["Free food and Drinks", "Island Leisure"],
                guideLanguage: ["Bahasa Indonesia"]
            )
        )
        moreInfo = [
            ActivitySectionLayout(title: "Things to Prepare", content: "Things to prepare content"),
            ActivitySectionLayout(title: "Provider Contact", content: "Provider contact content"),
            ActivitySectionLayout(title: "Term and Conditions", content: response.cancelable)
        ]

        availablePackages = ActivitySectionLayout(
            title: "Available Packages",
            content: response.packages.map {
                Package(
                    imageUrlString: $0.imageUrl,
                    name: $0.name,
                    description: "Min.\($0.minParticipants) - Max.\($0.maxParticipants)",
                    price: "Rp\($0.pricePerPerson)",
                    id: $0.id
                )
            }
        )

        hiddenPackages = Array(availablePackages.content.prefix(2))
    }
}

struct ActivitySectionLayout<T: Equatable>: Equatable {
    let title: String
    let content: T
}
