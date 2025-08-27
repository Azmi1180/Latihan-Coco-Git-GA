//
//  ActivityDetailViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation

final class ActivityDetailViewModel {
    weak var actionDelegate: ActivityDetailViewModelAction?
    weak var navigationDelegate: ActivityDetailNavigationDelegate?

    init(data: ActivityDetailDataModel, verificationService: ActivityVerificationServiceProtocol = ActivityVerificationService()) {
        self.data = data
        self.verificationService = verificationService
    }

    private let data: ActivityDetailDataModel
    private let verificationService: ActivityVerificationServiceProtocol
}

extension ActivityDetailViewModel: ActivityDetailViewModelProtocol {
    func onViewDidLoad() {
        // First, show the view with initial data immediately
        actionDelegate?.activityDetailData = data
        actionDelegate?.configureView(data: data)
        
        // Then, fetch verification status and update only if different from default
        Task {
            async let isVerified = verificationService.isActivityVerified(activityId: data.activityId)
            async let whatsIncludedData = verificationService.getWhatsIncludedData(activityId: data.activityId)
            
            let (verified, whatsIncluded) = await (isVerified, whatsIncludedData)
            
            // Only update if verification status is different or if tags are different from default
            if verified != data.isVerified || !areWhatsIncludedEqual(whatsIncluded, data.whatsIncluded.content) {
                let updatedData = data.withUpdatedWhatsIncluded(whatsIncluded, isVerified: verified)
                
                await MainActor.run {
                    actionDelegate?.updateVerificationAndWhatsIncluded(updatedData)
                }
            }
        }
    }
    
    private func areWhatsIncludedEqual(_ new: ActivityDetailDataModel.WhatsIncluded, _ current: ActivityDetailDataModel.WhatsIncluded) -> Bool {
        return new.providerAndSafety == current.providerAndSafety &&
               new.equipment == current.equipment &&
               new.services == current.services &&
               new.guideLanguage == current.guideLanguage
    }

    func onPackagesDetailDidTap(with packageId: Int) {
        navigationDelegate?.notifyActivityDetailPackageDidSelect(package: data, selectedPackageId: packageId)
    }

    func getPackages() -> [ActivityDetailDataModel.Package] {
        return data.availablePackages.content
    }
}
