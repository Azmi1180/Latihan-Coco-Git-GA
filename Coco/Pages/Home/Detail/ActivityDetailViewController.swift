//
//  ActivityDetailViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

final class ActivityDetailViewController: UIViewController {
    var activityDetailData: ActivityDetailDataModel?

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
    func notifyPackagesButtonDidTap() {
        guard let packages = activityDetailData?.availablePackages.content else { return }
        let bottomSheetVC = PackageListBottomSheetViewController(packages: packages)
        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(bottomSheetVC, animated: true, completion: nil)
    }

    func notifyPackagesDetailDidTap(with packageId: Int) {
        viewModel.onPackagesDetailDidTap(with: packageId)
    }
}
