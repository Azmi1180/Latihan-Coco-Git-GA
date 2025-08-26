//
//  HomeSearchFilterTrayDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 09/07/25.
//

import Foundation

struct HomeSearchFilterTrayDataModel {
    var filterPillDataState: [HomeSearchFilterPillState] = []
    var priceRangeModel: HomeSearchFilterPriceRangeModel
    var isVerifiedProviderEnabled: Bool

    init(filterPillDataState: [HomeSearchFilterPillState], priceRangeModel: HomeSearchFilterPriceRangeModel, isVerifiedProviderEnabled: Bool) {
        self.filterPillDataState = filterPillDataState
        self.priceRangeModel = priceRangeModel
        self.isVerifiedProviderEnabled = isVerifiedProviderEnabled
    }
}
