//
//  ActivityDetailViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

final class ActivityDetailViewController: UIViewController {
    init(viewModel: ActivityDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = thisView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        thisView.delegate = self
        viewModel.onViewDidLoad()
    }

    private let viewModel: ActivityDetailViewModelProtocol
    private let thisView: ActivityDetailView = ActivityDetailView()
}

extension ActivityDetailViewController: ActivityDetailViewModelAction {
    func configureView(data: ActivityDetailDataModel) {
        print("🕵️ DEBUG: Memeriksa isi ActivityDetailDataModel...")
        dump(data)
        print("-------------------------------------------------")
        
        thisView.configureView(data)

        if data.imageUrlsString.isEmpty {
            thisView.toggleImageSliderView(isShown: false)
        }
        else {
            thisView.toggleImageSliderView(isShown: true)
            let sliderVCs: ImageSliderHostingController = ImageSliderHostingController(images: data.imageUrlsString)
            addChild(sliderVCs)
            thisView.addImageSliderView(with: sliderVCs.view)
            sliderVCs.didMove(toParent: self)
        }
    }

    func updatePackageData(data: [ActivityDetailDataModel.Package]) {
        thisView.updatePackageData(data)
    }
    
    func updateVerificationAndWhatsIncluded(_ data: ActivityDetailDataModel) {
        thisView.updateVerificationAndWhatsIncluded(data)
    }
}

extension ActivityDetailViewController: ActivityDetailViewDelegate {
    func notifyPackagesButtonDidTap(shouldShowAll: Bool) {
        viewModel.onPackageDetailStateDidChange(shouldShowAll: shouldShowAll)
    }

    func notifyPackagesDetailDidTap(with packageId: Int) {
        viewModel.onPackagesDetailDidTap(with: packageId)
    }
    
    func notifyVerifiedProviderDidTap() {
        let modalView = VerificationInfoModalView()
        modalView.frame = view.bounds
        modalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add a fade-in animation
        modalView.alpha = 0
        view.addSubview(modalView)
        UIView.animate(withDuration: 0.3) {
            modalView.alpha = 1
        }
        
        // Set the closure to remove the modal with a fade-out animation
        modalView.onClose = { [weak modalView] in
            UIView.animate(withDuration: 0.3, animations: {
                modalView?.alpha = 0
            }, completion: { _ in
                modalView?.removeFromSuperview()
            })
        }
    }
    
    func notifyFamilyFriendlyBadgeDidTap() {
        let badgeInfoVC = BadgeInformationViewController()
        if let sheet = badgeInfoVC.sheetPresentationController {
            let height = self.view.bounds.height * 0.8
            let customDetent = UISheetPresentationController.Detent.custom { _ in
                return height
            }
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(badgeInfoVC, animated: true, completion: nil)
    }
}
