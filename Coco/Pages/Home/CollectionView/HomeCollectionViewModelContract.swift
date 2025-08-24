//
//  HomeCollectionViewModelContract.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation

protocol HomeCollectionViewModelDelegate: AnyObject {
    func notifyCollectionViewActivityDidTap(_ dataModel: HomeActivityCellDataModel)
}

protocol HomeCollectionViewModelAction: AnyObject {
    func configureDataSource()
    func applySnapshot(_ snapshot: HomeCollectionViewSnapShot, completion: (() -> Void)?)
}

struct HomeSectionData {
    let sectionType: HomeCollectionContent.SectionType
    let sectionDataModel: HomeActivityCellSectionDataModel
}

protocol HomeCollectionViewModelProtocol: AnyObject {
    var actionDelegate: HomeCollectionViewModelAction? { get set }
    var delegate: HomeCollectionViewModelDelegate? { get set }

    var activityData: [HomeSectionData] { get } // Updated type

    func onViewDidLoad()
    func updateActivity(sections: [HomeSectionData]) // Updated parameter name and type
    func onActivityDidTap(_ dataModel: HomeActivityCellDataModel)
}
