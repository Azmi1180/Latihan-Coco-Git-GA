
//
//  ResultViewModelContract.swift
//  Coco
//
//  Created by Reynard on 25/08/25.
//

import Foundation

protocol ResultViewModelProtocol: AnyObject {
    var actionDelegate: ResultViewModelAction? { get set }
    func onViewDidLoad()
}

protocol ResultViewModelAction: AnyObject {
    func constructCollectionView(viewModel: some HomeCollectionViewModelProtocol)
    func constructNavBar(viewModel: HomeSearchBarViewModel)
    func notifySearchBarTappedForNavigation()
}
