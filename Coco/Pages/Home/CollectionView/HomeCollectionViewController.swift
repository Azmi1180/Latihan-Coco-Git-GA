//
//  HomeCollectionViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation
import UIKit

final class HomeCollectionViewController: UIViewController {
    init(viewModel: HomeCollectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground // Tambahkan background color
        viewModel.onViewDidLoad()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = collectionView
    }

    var dataSource: HomeCollectionViewDataSource?

    private let viewModel: HomeCollectionViewModelProtocol
    private lazy var collectionView: UICollectionView = createCollectionView()
}

extension HomeCollectionViewController: HomeCollectionViewModelAction {
    func configureDataSource() {
        let activityCellRegistration: ActivityCellRegistration = createActivityCellRegistration()
        let headerRegistration: HeaderRegistration = createHeaderRegistration()

        let otherDestinationCellRegistration: OtherDestinationCellRegistration = createOtherDestinationCellRegistration()

                dataSource = HomeCollectionViewDataSource(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, item: AnyHashable) -> UICollectionViewCell? in
            guard let self = self,
                  let sectionIdentifier = self.dataSource?.sectionIdentifier(for: indexPath.section) else {
                return nil
            }

            switch item {
            case let item as HomeActivityCellDataModel:
                switch sectionIdentifier.type {
                case .popularDestination, .familyTopPick:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: activityCellRegistration, for: indexPath, item: item)
                    return cell
                case .activity:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: otherDestinationCellRegistration, for: indexPath, item: item)
                    return cell
                }
            default:
                return nil
            }
        })

        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            }

            return nil
        }
    }

    func applySnapshot(_ snapshot: HomeCollectionViewSnapShot, completion: (() -> Void)?) {
        dataSource?.apply(snapshot, completion: completion)
    }
}

extension HomeCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item: AnyHashable = dataSource?.itemIdentifier(for: indexPath) else {
             return
        }

        switch item {
        case let item as HomeActivityCellDataModel:
            viewModel.onActivityDidTap(item)
        default:
            break
        }
    }
}

private extension HomeCollectionViewController {
    func createCollectionView() -> UICollectionView {
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 8.0, right: 0)
        collectionView.backgroundColor = .systemBackground // Tambahkan background color
        return collectionView
    }

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionIdentifier = self?.dataSource?.sectionIdentifier(for: sectionIndex) else { return nil }

            switch sectionIdentifier.type {
            case .popularDestination, .familyTopPick:
                // Item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(217)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // Group (horizontal container)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(200), // Ubah dari fractionalWidth(1.0) ke absolute(200)
                    heightDimension: .absolute(217)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10 // Adjust spacing for vertical layout
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20.0, bottom: 8.0, trailing: 20.0) // Adjust insets

                // Header
                let headerHeight: NSCollectionLayoutDimension
                if sectionIdentifier.title == HomeViewModel.searchResultSectionTitle {
                    headerHeight = .absolute(0)
                } else {
                    headerHeight = .estimated(44)
                }
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: headerHeight
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]

                return section

            case .activity:
                // Item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(335), // Set to absolute width
                    heightDimension: .absolute(356) // Set to absolute height
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // Group (vertical container)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(335), // Set to absolute width
                    heightDimension: .absolute(356) // Set to absolute height
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .none // Change to vertical scrolling
                section.interGroupSpacing = 10 // Adjust spacing for vertical layout
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20.0, bottom: 8.0, trailing: 20.0) // Adjust insets // Adjust insets

                // Header
                let headerHeight: NSCollectionLayoutDimension
                if sectionIdentifier.title == HomeViewModel.searchResultSectionTitle {
                    headerHeight = .absolute(0)
                } else {
                    headerHeight = .estimated(44)
                }
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: headerHeight
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]

                return section
            }
            }
        }
    }


// MARK: Cell Registration
// MARK: Cell Registration
private extension HomeCollectionViewController {
    typealias ActivityCellRegistration = UICollectionView.CellRegistration<HomeActivityCell, HomeActivityCellDataModel>
    func createActivityCellRegistration() -> ActivityCellRegistration {
        .init { cell, _, itemIdentifier in
            cell.configureCell(itemIdentifier)
        }
    }

    typealias OtherDestinationCellRegistration = UICollectionView.CellRegistration<HomeOtherDestinationCell, HomeActivityCellDataModel>
    func createOtherDestinationCellRegistration() -> OtherDestinationCellRegistration {
        .init { cell, _, itemIdentifier in
            cell.configureCell(itemIdentifier, isFamilyFriendly: itemIdentifier.isFamilyFriendly)
        }
    }

    typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<HomeReusableHeader>
    func createHeaderRegistration() -> HeaderRegistration {
        .init(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, _, indexPath in
            guard let section: HomeCollectionContent.Section = self.dataSource?.sectionIdentifier(for: indexPath.section),
                  let sectionTitle: String = section.title
            else {
                return
            }

            let isHidden = (sectionTitle == HomeViewModel.searchResultSectionTitle)

            var iconName: String? = nil
            switch section.type {
            case .popularDestination:
                iconName = "star.fill"
            case .familyTopPick:
                iconName = "heart.fill"
            case .activity:
                iconName = "mappin.circle.fill"
            }

            supplementaryView.configureView(title: sectionTitle, isHidden: isHidden, iconName: iconName)
        }
    }
}
