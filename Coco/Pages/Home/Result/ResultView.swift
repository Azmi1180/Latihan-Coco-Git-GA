//
//  ResultView.swift
//  Coco
//
//  Created by Reynard on 25/08/25.
//

import Foundation
import UIKit

final class ResultView: UIView {
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground // Use system background for light/dark mode support
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    // Adds the Search Bar child view with the correct padding.
    func addSearchBarView(from view: UIView) {
        // Clear previous views to prevent duplicates
        searchBarView.subviews.forEach { $0.removeFromSuperview() }
        // Adds the new view with insets matching HomeView
        searchBarView.addSubviewAndLayout(view, insets: .init(top: 20, left: 20, bottom: 12, right: 20))
    }
    
    // Adds the CollectionView/Search Results child view.
    func addSearchResultView(from view: UIView) {
        // Clear previous views
        searchResultView.subviews.forEach { $0.removeFromSuperview() }
        searchResultView.addSubviewAndLayout(view)
    }
    
    // The following methods are added for full consistency with HomeView,
    // allowing you to easily add loading or error states in the future.
    func addErrorView(from view: UIView) {
        errorView.subviews.forEach { $0.removeFromSuperview() }
        errorView.addSubviewAndLayout(view)
    }

    func addLoadingView(from view: UIView) {
        loadingView.subviews.forEach { $0.removeFromSuperview() }
        loadingView.addSubviewAndLayout(view)
    }

    func toggleErrorView(isShown: Bool) {
        errorView.isHidden = !isShown
    }

    func toggleLoadingView(isShown: Bool) {
        loadingView.isHidden = !isShown
    }
    
    // MARK: - Private Properties
    
    private lazy var errorView: UIView = UIView()
    private lazy var loadingView: UIView = UIView()
    private lazy var searchBarView: UIView = UIView()
    private lazy var searchResultView: UIView = UIView()
    private lazy var contentStackView: UIStackView = createContentStackView()
}

// MARK: - Private Setup Methods
private extension ResultView {
    
    func setupView() {
        // Add the main stack view that holds the content
        addSubviewAndLayout(contentStackView)
        
        // Add overlay views for error and loading states
        addSubviewAndLayout(errorView)
        addSubviewAndLayout(loadingView)

        // Hide overlays by default
        errorView.isHidden = true
        loadingView.isHidden = true
    }

    func createContentStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            searchBarView,
            searchResultView,
        ])
        stackView.axis = .vertical
        stackView.spacing = 12.0 // This matches the spacing in HomeView
        return stackView
    }
}

// Note: This implementation assumes you have the `addSubviewAndLayout` helper
// extension on UIView, as it is used in your HomeView. If not, you'll need
// to add it. Here's a likely implementation:
/*
extension UIView {
    func addSubviewAndLayout(_ subview: UIView, insets: UIEdgeInsets = .zero) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top),
            subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left),
            subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right),
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
*/
