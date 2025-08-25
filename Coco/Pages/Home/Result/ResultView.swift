
//
//  ResultView.swift
//  Coco
//
//  Created by Reynard on 25/08/25.
//

import Foundation
import UIKit

class ResultView: UIView {
    private let searchBarContainerView = UIView()
    private let collectionViewContainerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(searchBarContainerView)
        addSubview(collectionViewContainerView)
        
        searchBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBarContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchBarContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBarContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            collectionViewContainerView.topAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor),
            collectionViewContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionViewContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionViewContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func addSearchBarView(from view: UIView) {
        searchBarContainerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: searchBarContainerView.topAnchor),
            view.leadingAnchor.constraint(equalTo: searchBarContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: searchBarContainerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor)
        ])
    }
    
    func addCollectionView(from view: UIView) {
        collectionViewContainerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: collectionViewContainerView.topAnchor),
            view.leadingAnchor.constraint(equalTo: collectionViewContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionViewContainerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: collectionViewContainerView.bottomAnchor)
        ])
    }
}
