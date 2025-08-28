//
//  ActivityDetailDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation

struct ActivityDetailDataModel: Equatable {
    let activityId: Int
    let title: String
    let location: String
    let imageUrlsString: [String]
    let isVerified: Bool

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
        let pax: String
        let ageRange: String
        let price: String

        let id: Int
    }

    init(_ response: Activity) {
        activityId = response.id
        title = response.title
        location = response.destination.name
        imageUrlsString = response.images
            .filter { $0.imageType != .banner }
            .map { $0.imageUrl }
        isVerified = false // Will be updated after verification check

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
        // swiftlint::disable line_length
        moreInfo = [
            ActivitySectionLayout(
                title: "Things to Prepare",
                content: "Swimwear, change of clothes, and towel\nPersonal medicine (if needed)\nSunscreen & hat\nWaterproof phone case or camera\nExtra snacks for kids (optional)"
            ),
            ActivitySectionLayout(
                title: "Provider Contact",
                content: "West Bali National Park, Bali\n+62-829-8888-333\nwww.nusapenidaecotour.com"
            ),
            ActivitySectionLayout(
                title: "Term and Conditions",
                content: response.cancelable
            )
        ]
        // swiftlint::enable line_length

        availablePackages = ActivitySectionLayout(
            title: "Available Packages",
            content: response.packages.map {
                Package(
                    imageUrlString: $0.imageUrl,
                    name: $0.name,
                    pax: "\($0.minParticipants)-\($0.maxParticipants)",
                    ageRange: "Ages 5-65", // This is a placeholder
                    price: "Rp \($0.pricePerPerson)",
                    id: $0.id
                )
            }
        )

        hiddenPackages = Array(availablePackages.content.prefix(2))
    }
    
    func withVerificationStatus(_ isVerified: Bool) -> ActivityDetailDataModel {
        return ActivityDetailDataModel(
            activityId: self.activityId,
            title: self.title,
            location: self.location,
            imageUrlsString: self.imageUrlsString,
            isVerified: isVerified,
            detailInfomation: self.detailInfomation,
            providerDetail: self.providerDetail,
            whatsIncluded: self.whatsIncluded,
            moreInfo: self.moreInfo,
            availablePackages: self.availablePackages,
            hiddenPackages: self.hiddenPackages
        )
    }
    
    func withUpdatedWhatsIncluded(_ whatsIncluded: WhatsIncluded, isVerified: Bool) -> ActivityDetailDataModel {
        return ActivityDetailDataModel(
            activityId: self.activityId,
            title: self.title,
            location: self.location,
            imageUrlsString: self.imageUrlsString,
            isVerified: isVerified,
            detailInfomation: self.detailInfomation,
            providerDetail: self.providerDetail,
            whatsIncluded: ActivitySectionLayout(title: "What's Included", content: whatsIncluded),
            moreInfo: self.moreInfo,
            availablePackages: self.availablePackages,
            hiddenPackages: self.hiddenPackages
        )
    }
    
    private init(
        activityId: Int,
        title: String,
        location: String,
        imageUrlsString: [String],
        isVerified: Bool,
        detailInfomation: ActivitySectionLayout<String>,
        providerDetail: ActivitySectionLayout<ProviderDetail>,
        whatsIncluded: ActivitySectionLayout<WhatsIncluded>,
        moreInfo: [ActivitySectionLayout<String>],
        availablePackages: ActivitySectionLayout<[Package]>,
        hiddenPackages: [Package]
    ) {
        self.activityId = activityId
        self.title = title
        self.location = location
        self.imageUrlsString = imageUrlsString
        self.isVerified = isVerified
        self.detailInfomation = detailInfomation
        self.providerDetail = providerDetail
        self.whatsIncluded = whatsIncluded
        self.moreInfo = moreInfo
        self.availablePackages = availablePackages
        self.hiddenPackages = hiddenPackages
    }
}

struct ActivitySectionLayout<T: Equatable>: Equatable {
    let title: String
    let content: T
}
