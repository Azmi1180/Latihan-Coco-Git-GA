//
//  HomeCollectionViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation
import UIKit

final class HomeCollectionViewModel: NSObject, HomeCollectionViewModelProtocol {
    weak var delegate: HomeCollectionViewModelDelegate?
    weak var actionDelegate: HomeCollectionViewModelAction? // Add this

    private(set) var activityData: [HomeSectionData] = [] // Updated type

    func onViewDidLoad() {
        // Only Called Once
        actionDelegate?.configureDataSource()
        reloadCollection()
    }

    func onActivityDidTap(_ dataModel: HomeActivityCellDataModel) {
        delegate?.notifyCollectionViewActivityDidTap(dataModel)
    }

    func updateActivity(sections: [HomeSectionData]) { // Updated parameter name and type
        self.activityData = sections
        // Replace collectionView.reloadData() with applySnapshot
        actionDelegate?.applySnapshot(createSnapshot(), completion: nil)
    }
}

private extension HomeCollectionViewModel {
    func reloadCollection() {
        actionDelegate?.applySnapshot(createSnapshot(), completion: {
            // do nothing
        })
    }

    func createSnapshot() -> HomeCollectionViewSnapShot {
        var snapshot = HomeCollectionViewSnapShot()

        for sectionData in activityData {
            guard !sectionData.sectionDataModel.dataModel.isEmpty else {
                continue
            }

            let section = HomeCollectionContent.Section(
                type: sectionData.sectionType,
                title: sectionData.sectionDataModel.title
            )
            snapshot.appendSections([section])
            snapshot.appendItems(sectionData.sectionDataModel.dataModel, toSection: section)
        }

        return snapshot
    }
}
