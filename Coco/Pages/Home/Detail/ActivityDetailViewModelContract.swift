//
//  ActivityDetailViewModelContract.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation

protocol ActivityDetailNavigationDelegate: AnyObject {
    func notifyActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int)
}

protocol ActivityDetailViewModelAction: AnyObject {
    var activityDetailData: ActivityDetailDataModel? { get set }
    func configureView(data: ActivityDetailDataModel)
    func updatePackageData(data: [ActivityDetailDataModel.Package])
    func updateVerificationAndWhatsIncluded(_ data: ActivityDetailDataModel)
}

protocol ActivityDetailViewModelProtocol: AnyObject {
    var actionDelegate: ActivityDetailViewModelAction? { get set }
    var navigationDelegate: ActivityDetailNavigationDelegate? { get set }

    func onViewDidLoad()
    func onPackagesDetailDidTap(with packageId: Int)
    func getPackages() -> [ActivityDetailDataModel.Package]
}
