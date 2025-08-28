//
//  BadgeInformationViewController.swift
//  Coco
//
//  Created by Copilot on 28/08/25.
//

import UIKit

class BadgeInformationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .white
        
        let mainStack = createStackView(spacing: 24, axis: .vertical)
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        
        // Header
        let headerStack = createStackView(spacing: 8, axis: .horizontal)
        headerStack.alignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = "Badges Information"
        titleLabel.font = .jakartaSans(forTextStyle: .headline, weight: .bold)
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(UIView()) // Spacer
        headerStack.addArrangedSubview(closeButton)
        
        // Badge
        let badge = createFamilyFriendlyBadge()
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Trips safe for kids, with facilities and activities for all ages. The Family-Friendly badge appears only when the package includes all required features, ensuring a worry-free experience for parents and children."
        descriptionLabel.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        descriptionLabel.textColor = Token.grayscale90
        descriptionLabel.numberOfLines = 0
        
        // Tags
        let tags = [
            "Certified guide", "Multi-size gear", "Safe access zone", "First aid kit",
            "Free cancellation", "Pre-snorkeling edu", "Emergency procedures", "Refreshment booth",
            "Shallow spots", "Rest areas", "Shower room", "Baby care room", "Island leisure"
        ]
        let tagsView = createTagsView(tags: tags)
        
        mainStack.addArrangedSubview(headerStack)
        mainStack.addArrangedSubview(badge)
        mainStack.addArrangedSubview(descriptionLabel)
        mainStack.addArrangedSubview(tagsView)
        
        view.addSubview(mainStack)
        mainStack.layout {
            $0.top(to: view.safeAreaLayoutGuide.topAnchor)
            $0.leading(to: view.leadingAnchor)
            $0.trailing(to: view.trailingAnchor)
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func createStackView(spacing: CGFloat, axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView()
        stackView.spacing = spacing
        stackView.axis = axis
        return stackView
    }
    
    private func createFamilyFriendlyBadge() -> UIView {
        let badgeContainer = createStackView(spacing: 6, axis: .horizontal)
        badgeContainer.alignment = .center
        badgeContainer.isLayoutMarginsRelativeArrangement = true
        badgeContainer.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        badgeContainer.layer.cornerRadius = 18
        badgeContainer.backgroundColor = UIColor.from("#B9EC63")

        let familyIconView = UIImageView(image: UIImage(named: "familyIcon"))
        familyIconView.layout { $0.size(22) }

        let label = UILabel()
        label.text = "Family-Friendly"
        label.font = .jakartaSans(forTextStyle: .callout, weight: .medium)
        label.textColor = .black

        badgeContainer.addArrangedSubview(familyIconView)
        badgeContainer.addArrangedSubview(label)
        
        let hStack = createStackView(spacing: 0, axis: .horizontal)
        hStack.addArrangedSubview(badgeContainer)
        hStack.addArrangedSubview(UIView()) // Spacer
        
        return hStack
    }
    
    private func createTagsView(tags: [String]) -> UIView {
        let tagsContainer = UIView()
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let spacing: CGFloat = 8
        
        for tag in tags {
            let tagView = createTagPill(text: tag)
            let tagSize = tagView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            if currentX + tagSize.width > UIScreen.main.bounds.width - 48 { // 24 padding on each side
                currentX = 0
                currentY += tagSize.height + spacing
            }
            
            tagView.frame = CGRect(x: currentX, y: currentY, width: tagSize.width, height: tagSize.height)
            tagsContainer.addSubview(tagView)
            currentX += tagSize.width + spacing
        }
        
        tagsContainer.heightAnchor.constraint(equalToConstant: currentY + 30).isActive = true
        
        return tagsContainer
    }
    
    private func createTagPill(text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .jakartaSans(forTextStyle: .caption1, weight: .medium)
        label.textColor = Token.grayscale70
        
        let container = UIView()
        container.backgroundColor = Token.grayscale20
        container.layer.cornerRadius = 15
        container.addSubview(label)
        
        label.layout {
            $0.top(to: container.topAnchor, constant: 8)
            $0.bottom(to: container.bottomAnchor, constant: -8)
            $0.leading(to: container.leadingAnchor, constant: 12)
            $0.trailing(to: container.trailingAnchor, constant: -12)
        }
        
        return container
    }
}
