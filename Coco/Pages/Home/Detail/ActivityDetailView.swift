//
//  ActivityDetailView.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

protocol ActivityDetailViewDelegate: AnyObject {
    func notifyPackagesButtonDidTap()
    func notifyPackagesDetailDidTap(with packageId: Int)
}

final class ActivityDetailView: UIView {
    weak var delegate: ActivityDetailViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureView(_ data: ActivityDetailDataModel) {
        // Clear existing content to avoid duplication
        contentStackView.arrangedSubviews.forEach { view in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        packageContainer.arrangedSubviews.forEach { view in
            packageContainer.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        titleLabel.text = data.title
        locationLabel.text = data.location

        // Detail section
        let detailDescription: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .regular),
            textColor: Token.grayscale70,
            numberOfLines: 0
        )
        detailDescription.text = data.detailInfomation.content
        contentStackView.addArrangedSubview(
            createSectionView(
                title: data.detailInfomation.title,
                view: detailDescription
            )
        )

        contentStackView.addArrangedSubview(createDividerView())

        // Trip Provider
        contentStackView.addArrangedSubview(
            createSectionView(
                title: data.providerDetail.title,
                view: createProviderDetail(
                    imageUrl: data.providerDetail.content.imageUrlString,
                    name: data.providerDetail.content.name,
                    description: data.providerDetail.content.description,
                    isVerified: data.isVerified
                )
            )
        )

        contentStackView.addArrangedSubview(createDividerView())

        if !data.availablePackages.content.isEmpty {
            contentStackView.addArrangedSubview(packageSection)

            totalPackageCount = data.availablePackages.content.count
            
            if data.availablePackages.content.count <= 2 {
                packageButton.isHidden = true
            } else {
                packageButton.isHidden = false
                updatePackageButtonText()
            }

            packageLabel.text = data.availablePackages.title
            updatePackageData(data.availablePackages.content)
        }

        packageLabel.isHidden = data.availablePackages.content.isEmpty

        contentStackView.addArrangedSubview(createDividerView())

        // What's Included
        contentStackView.addArrangedSubview(
            createSectionView(
                title: data.whatsIncluded.title,
                view: createWhatsIncludedView(with: data.whatsIncluded.content)
            )
        )

        contentStackView.addArrangedSubview(createDividerView())

        // More Info
        let moreInfoContentStackView = createStackView(spacing: 16.0)
        data.moreInfo.forEach { info in
            let contentView: UIView
            switch info.title {
            case "Provider Contact":
                contentView = createProviderContactView(from: info.content)
            default:
                let items = info.content.split(separator: "\n").map { String($0) }
                contentView = createBenefitListView(titles: items)
            }
            
            let accordion = AccordionView(title: info.title, contentView: contentView)
            moreInfoContentStackView.addArrangedSubview(accordion)
        }
        contentStackView.addArrangedSubview(
            createSectionView(
                title: "More Info",
                view: moreInfoContentStackView
            )
        )
    }

    func addImageSliderView(with view: UIView) {
        imageSliderView.subviews.forEach { $0.removeFromSuperview() }
        imageSliderView.addSubviewAndLayout(view)
    }


    func toggleImageSliderView(isShown: Bool) {
        imageSliderView.isHidden = !isShown
    }

    func updatePackageData(_ data: [ActivityDetailDataModel.Package]) {
        // Clear existing packages
        packageContainer.arrangedSubviews.forEach { 
            packageContainer.removeArrangedSubview($0)
            $0.removeFromSuperview() 
        }

        // Show only first 2 packages
        let packagesToShow = Array(data.prefix(2))

        for (index, item) in packagesToShow.enumerated() {
            let view: UIView = createPackageView(data: item)
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 8)
            packageContainer.addArrangedSubview(view)

            UIView.animate(
                withDuration: 0.3,
                delay: 0.05 * Double(index),
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut],
                animations: {
                    view.alpha = 1
                    view.transform = .identity
                }
            )
        }
    }
    
    func updateVerificationAndWhatsIncluded(_ data: ActivityDetailDataModel) {
        // Find and update only the provider section and what's included section
        // This avoids rebuilding the entire view
        configureView(data)
    }

    private lazy var imageSliderView: UIView = UIView()
    private lazy var titleView: UIView = createTitleView()
    private lazy var titleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title2, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )

    private lazy var locationLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )

    private lazy var packageSection: UIView = createPackageSection()
    private lazy var packageLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .headline, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var packageButton: UIButton = createPackageTextButton()

    private lazy var packageContainer: UIStackView = createStackView(spacing: 18.0)
    private lazy var contentStackView: UIStackView = createStackView(spacing: 29.0)
    private lazy var headerStackView: UIStackView = createStackView(spacing: 0)

    private var totalPackageCount: Int = 0
}

extension ActivityDetailView {
    func setupView() {
        let scrollView: UIScrollView = UIScrollView()
        let contentView: UIView = UIView()

        scrollView.addSubviewAndLayout(contentView)
        contentView.layout {
            $0.widthAnchor(to: scrollView.widthAnchor)
        }

        addSubviewAndLayout(scrollView)

        contentView.addSubviews([
            headerStackView,
            contentStackView
        ])

        headerStackView.backgroundColor = UIColor.from("#F5F5F5")
        headerStackView.addArrangedSubview(imageSliderView)
        headerStackView.addArrangedSubview(titleView)

        headerStackView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }

        contentStackView.layout {
            $0.top(to: headerStackView.bottomAnchor, constant: -8.0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }

        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .init(vertical: 20.0, horizontal: 15.0)
        contentStackView.layer.cornerRadius = 24.0
        contentStackView.backgroundColor = Token.additionalColorsWhite

        scrollView.backgroundColor = UIColor.from("#F5F5F5")

        imageSliderView.isHidden = true
    }
}

private extension ActivityDetailView {
    func createStackView(
        spacing: CGFloat,
        axis: NSLayoutConstraint.Axis = .vertical
    ) -> UIStackView {
        let stackView: UIStackView = UIStackView()
        stackView.spacing = spacing
        stackView.axis = axis

        return stackView
    }

    func createSectionView(title: String, view: UIView) -> UIView {
        let contentView: UIView = UIView()
        let titleLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        titleLabel.text = title

        contentView.addSubviews([
            titleLabel,
            view
        ])

        titleLabel.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }

        view.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 12.0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }

        return contentView
    }

    func createIconTextView(image: UIImage, text: String) -> UIView {
        let imageView: UIImageView = UIImageView(image: image)
        imageView.layout {
            $0.size(20.0)
        }

        let label: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale90,
            numberOfLines: 2
        )
        label.text = text

        let containerView: UIView = UIView()
        containerView.addSubviews([
            imageView,
            label
        ])

        imageView.layout {
            $0.leading(to: containerView.leadingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }

        label.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 4.0)
                .trailing(to: containerView.trailingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }

        return containerView
    }

    func createTitleView() -> UIView {
        let pinPointImage: UIImageView = UIImageView(image: CocoIcon.icPinPointBlue.image)
        pinPointImage.layout {
            $0.size(20.0)
        }

        let locationView: UIView = UIView()
        locationView.addSubviews([
            pinPointImage,
            locationLabel
        ])

        pinPointImage.layout {
            $0.leading(to: locationView.leadingAnchor)
                .bottom(to: locationView.bottomAnchor)
                .top(to: locationView.topAnchor)
        }

        locationLabel.layout {
            $0.leading(to: pinPointImage.trailingAnchor, constant: 4.0)
                .trailing(to: locationView.trailingAnchor)
                .centerY(to: locationView.centerYAnchor)
        }

        let contentView: UIView = UIView()
        contentView.addSubviews([
            titleLabel,
            locationView
        ])

        titleLabel.layout {
            $0.leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .top(to: contentView.topAnchor)
        }

        locationView.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8.0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }

        let contentWrapperView: UIView = UIView()
        contentWrapperView.addSubviewAndLayout(
            contentView,
            insets: .init(
                top: 16.0,
                left: 24.0,
                bottom: 16.0 + 8.0,
                right: 16.0
            )
        )

        return contentWrapperView
    }

    func createBenefitView(title: String) -> UIView {
        let container = createStackView(spacing: 8, axis: .horizontal)

        let bulletLabel = UILabel()
        bulletLabel.text = "•"
        bulletLabel.font = .jakartaSans(forTextStyle: .footnote, weight: .regular)
        bulletLabel.textColor = Token.additionalColorsBlack

        let benefitLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 0
        )
        benefitLabel.text = title

        container.addArrangedSubview(bulletLabel)
        container.addArrangedSubview(benefitLabel)

        bulletLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        return container
    }

    func createBenefitListView(titles: [String]) -> UIView {
        let stackView: UIStackView = createStackView(spacing: 12.0)

        titles.forEach { title in
            stackView.addArrangedSubview(createBenefitView(title: title))
        }

        return stackView
    }

    func createProviderDetail(imageUrl: String, name: String, description: String, isVerified: Bool = false) -> UIView {
        // Main horizontal stack view: Image + Text Block
        let mainHorizontalStack = createStackView(spacing: 12, axis: .horizontal)
        mainHorizontalStack.alignment = .top
        
        // Provider image
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout {
            $0.size(92.0)
        }
        imageView.layer.cornerRadius = 14.0
        imageView.loadImage(from: URL(string: imageUrl))
        imageView.clipsToBounds = true
        
        // Provider text block (vertical stack)
        let textBlockStack = createStackView(spacing: 8, axis: .vertical)
        textBlockStack.alignment = .leading
        
        // Top line: Provider name + verification badge
        let nameAndBadgeStack = createStackView(spacing: 6, axis: .horizontal)
        nameAndBadgeStack.alignment = .top
        
        let nameLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        nameLabel.text = name
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        nameAndBadgeStack.addArrangedSubview(nameLabel)
        
        // Add verification badge if verified
        if isVerified {
            let verificationBadge = createVerificationBadge()
            nameAndBadgeStack.addArrangedSubview(verificationBadge)
        }
        
        // Bottom line: "Verified Provider" + info icon (only if verified)
        let verifiedProviderStack: UIStackView?
        if isVerified {
            verifiedProviderStack = createStackView(spacing: 4, axis: .horizontal)
            verifiedProviderStack!.alignment = .center
            
            let verifiedLabel = UILabel(
                font: .jakartaSans(forTextStyle: .caption1, weight: .medium),
                textColor: Token.grayscale70,
                numberOfLines: 1
            )
            verifiedLabel.text = "Verified Provider"
            
            let infoImageView = UIImageView()
            infoImageView.image = UIImage(systemName: "info.circle")
            infoImageView.tintColor = Token.grayscale70
            infoImageView.contentMode = .scaleAspectFit
            infoImageView.layout {
                $0.size(16)
            }
            
            verifiedProviderStack!.addArrangedSubview(verifiedLabel)
            verifiedProviderStack!.addArrangedSubview(infoImageView)
        } else {
            verifiedProviderStack = nil
        }
        
        // Description label
        let descriptionLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale90,
            numberOfLines: 0
        )
        descriptionLabel.text = description
        
        // Add elements to text block stack
        textBlockStack.addArrangedSubview(nameAndBadgeStack)
        
        if let verifiedStack = verifiedProviderStack {
            textBlockStack.addArrangedSubview(verifiedStack)
        }
        
        textBlockStack.addArrangedSubview(descriptionLabel)
        
        // Add image and text block to main horizontal stack
        mainHorizontalStack.addArrangedSubview(imageView)
        mainHorizontalStack.addArrangedSubview(textBlockStack)
        
        return mainHorizontalStack
    }
    
    func createVerificationBadge() -> UIView {
        let containerView = UIView()
        
        // Use the shield checkmark SF Symbol
        let shieldImageView = UIImageView()
        shieldImageView.image = UIImage(systemName: "checkmark.shield.fill")
        shieldImageView.tintColor = UIColor.systemBlue
        shieldImageView.contentMode = .scaleAspectFit
        shieldImageView.layout {
            $0.size(20)
        }
        
        containerView.addSubview(shieldImageView)
        shieldImageView.layout {
            $0.edges(to: containerView)
        }
        
        return containerView
    }

    func createPackageView(data: ActivityDetailDataModel.Package) -> UIView {
        let mainStackView = createStackView(spacing: 16)
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .bold),
            textColor: Token.additionalColorsBlack
        )
        titleLabel.text = data.name
        
        let tagsStackView = createStackView(spacing: 8, axis: .horizontal)
       tagsStackView.addArrangedSubview(createTagView(text: data.pax, icon: UIImage(systemName: "Person")))
        tagsStackView.addArrangedSubview(createTagView(text: data.ageRange))
        tagsStackView.addArrangedSubview(UIView()) // Spacer
        
        let divider = createDottedDivider()
        
        let footerStackView = createStackView(spacing: 16, axis: .horizontal)
        footerStackView.alignment = .center
        
        let priceStackView = createStackView(spacing: 4)
        let startFromLabel = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .regular),
            textColor: Token.grayscale70
        )
        startFromLabel.text = "Start from"
        
        let priceLabel = UILabel()
        
        // Format the price with thousand separators
        let formattedPrice: String
        if let priceNumber = extractNumberFromPrice(data.price) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale(identifier: "id_ID") 
            formatter.groupingSeparator = "."
            formatter.usesGroupingSeparator = true
            formatter.maximumFractionDigits = 0
            
            if let formattedNumber = formatter.string(from: NSNumber(value: priceNumber)) {
                formattedPrice = "Rp \(formattedNumber)"
            } else {
                formattedPrice = data.price
            }
        } else {
            formattedPrice = data.price
        }
        
        let priceText = NSMutableAttributedString(
            string: formattedPrice,
            attributes: [
                .font: UIFont.jakartaSans(forTextStyle: .headline, weight: .bold),
                .foregroundColor: Token.additionalColorsBlack
            ]
        )
        priceText.append(NSAttributedString(
            string: " /Pax",
            attributes: [
                .font: UIFont.jakartaSans(forTextStyle: .caption1, weight: .regular),
                .foregroundColor: Token.grayscale70
            ]
        ))
        priceLabel.attributedText = priceText
        
        priceStackView.addArrangedSubview(startFromLabel)
        priceStackView.addArrangedSubview(priceLabel)
        
        let action: UIAction = UIAction { [weak self] _ in
            self?.delegate?.notifyPackagesDetailDidTap(with: data.id)
        }
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = Token.mainColorPrimary
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = .init(top: 12, leading: 24, bottom: 12, trailing: 24)
                
        config.attributedTitle = AttributedString(
            "Choose",
            attributes: AttributeContainer([
                .font: UIFont.jakartaSans(forTextStyle: .subheadline, weight: .semibold),
                .foregroundColor: UIColor.white
            ])
        )
        
        let chooseButton = UIButton(configuration: config, primaryAction: action)
                
        chooseButton.layout {
            $0.width(120)
        }
        
        footerStackView.addArrangedSubview(priceStackView)
        footerStackView.addArrangedSubview(chooseButton)
        
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(tagsStackView)
        mainStackView.addArrangedSubview(divider)
        mainStackView.addArrangedSubview(footerStackView)
        
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = .init(edges: 16.0)
        mainStackView.layer.cornerRadius = 16.0
        mainStackView.layer.borderWidth = 1.5
        mainStackView.layer.borderColor = Token.grayscale40.cgColor
        mainStackView.backgroundColor = .white

        return mainStackView
    }

    func createTagView(text: String, icon: UIImage? = nil) -> UIView {
        let stackView = createStackView(spacing: 4, axis: .horizontal)
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 6, left: 10, bottom: 6, right: 10)
        stackView.backgroundColor = Token.grayscale20
        stackView.layer.cornerRadius = 12
        
        if let icon = icon {
            let imageView = UIImageView(image: icon)
            imageView.tintColor = Token.grayscale70
            imageView.layout{ $0.size(14) }
            stackView.addArrangedSubview(imageView)
        }
        
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .medium),
            textColor: Token.grayscale70
        )
        label.text = text
        stackView.addArrangedSubview(label)
        
        return stackView
    }
    
    func createDottedDivider() -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        DispatchQueue.main.async {
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = Token.grayscale40.cgColor
            shapeLayer.lineWidth = 1
            shapeLayer.lineDashPattern = [4, 4] 
            
            let path = CGMutablePath()
            path.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: view.frame.width, y: 0)])
            shapeLayer.path = path
            view.layer.addSublayer(shapeLayer)
        }
        
        return view
    }

    func createPackageSection() -> UIView {
        let contentView: UIView = UIView()
        contentView.addSubviews([
            packageLabel,
            packageContainer,
            packageButton
        ])

        packageLabel.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }

        packageContainer.layout {
            $0.top(to: packageLabel.bottomAnchor, constant: 16.0)
            $0.leading(to: contentView.leadingAnchor)
            $0.trailing(to: contentView.trailingAnchor)
        }
        
        packageButton.layout {
            $0.top(to: packageContainer.bottomAnchor, constant: 16.0)
            $0.leading(to: contentView.leadingAnchor)
            $0.trailing(to: contentView.trailingAnchor)
            $0.bottom(to: contentView.bottomAnchor)
        }

        return contentView
    }

    func createPackageTextButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = "See All"
        config.baseForegroundColor = Token.mainColorPrimary
        config.contentInsets = .init(top: 16, leading: 20, bottom: 16, trailing: 20)
        
        let button = UIButton(configuration: config)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Token.mainColorPrimary.cgColor
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .jakartaSans(forTextStyle: .subheadline, weight: .medium)
        button.addTarget(self, action: #selector(didTapTextButton), for: .touchUpInside)
        
        // Set minimum height for the button
        button.layout {
            $0.height(50)
        }

        return button
    }

    @objc func didTapTextButton() {
        delegate?.notifyPackagesButtonDidTap()
    }
    
    func updatePackageButtonText() {
        packageButton.setTitle("See All (\(totalPackageCount))", for: .normal)
    }

    func createWhatsIncludedView(with data: ActivityDetailDataModel.WhatsIncluded) -> UIView {
        let mainStackView = createStackView(spacing: 16, axis: .horizontal)
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .top

        // Left Column
        let leftColumnStackView = createStackView(spacing: 16, axis: .vertical)

        let providerSafetyStack = createStackView(spacing: 8)
        let providerSafetyLabel = UILabel()
        providerSafetyLabel.text = "Provider & Safety"
        providerSafetyLabel.font = .jakartaSans(forTextStyle: .subheadline, weight: .bold)
        providerSafetyStack.addArrangedSubview(providerSafetyLabel)
        data.providerAndSafety.forEach {
            providerSafetyStack.addArrangedSubview(createBenefitView(title: $0))
        }
        leftColumnStackView.addArrangedSubview(providerSafetyStack)

        let servicesStack = createStackView(spacing: 8)
        let servicesLabel = UILabel()
        servicesLabel.text = "Services"
        servicesLabel.font = .jakartaSans(forTextStyle: .subheadline, weight: .bold)
        servicesStack.addArrangedSubview(servicesLabel)
        data.services.forEach {
            servicesStack.addArrangedSubview(createBenefitView(title: $0))
        }
        leftColumnStackView.addArrangedSubview(servicesStack)

        mainStackView.addArrangedSubview(leftColumnStackView)

        // Right Column
        let rightColumnStackView = createStackView(spacing: 16, axis: .vertical)

        let equipmentStack = createStackView(spacing: 8)
        let equipmentLabel = UILabel()
        equipmentLabel.text = "Equipment"
        equipmentLabel.font = .jakartaSans(forTextStyle: .subheadline, weight: .bold)
        equipmentStack.addArrangedSubview(equipmentLabel)
        data.equipment.forEach {
            equipmentStack.addArrangedSubview(createBenefitView(title: $0))
        }
        rightColumnStackView.addArrangedSubview(equipmentStack)

        let guideLanguageStack = createStackView(spacing: 8)
        let guideLanguageLabel = UILabel()
        guideLanguageLabel.text = "Guide Language"
        guideLanguageLabel.font = .jakartaSans(forTextStyle: .subheadline, weight: .bold)
        guideLanguageStack.addArrangedSubview(guideLanguageLabel)
        data.guideLanguage.forEach {
            guideLanguageStack.addArrangedSubview(createBenefitView(title: $0))
        }
        rightColumnStackView.addArrangedSubview(guideLanguageStack)

        mainStackView.addArrangedSubview(rightColumnStackView)

        return mainStackView
    }
    
    func createProviderContactView(from content: String) -> UIView {
        let items = content.split(separator: "\n").map { String($0) }
        let stackView = createStackView(spacing: 16)
        
        if items.count > 0 {
            stackView.addArrangedSubview(createIconTextView(image: CocoIcon.icPinPointBlue.image, text: items[0]))
        }
        if items.count > 1 {
            stackView.addArrangedSubview(createIconTextView(image: UIImage(systemName: "phone.fill")!, text: items[1]))
        }
        if items.count > 2 {
            stackView.addArrangedSubview(createIconTextView(image: UIImage(systemName: "globe")!, text: items[2]))
        }
        
        return stackView
    }
    
    func createDividerView() -> UIView {
        let divider = UIView()
        divider.backgroundColor = Token.grayscale40
        divider.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
        return divider
    }
    
    func extractNumberFromPrice(_ priceString: String) -> Double? {
        // Remove common currency symbols and letters, keep only numbers and dots/commas
        let cleanedString = priceString
            .replacingOccurrences(of: "Rp", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: "") // Remove commas if any
        
        return Double(cleanedString)
    }
    
    // func extractNumberFromPrice(_ priceString: String) -> Double? {
    //     // Remove common currency symbols and letters, keep only numbers and dots/commas
    //     let cleanedString = priceString
    //         .replacingOccurrences(of: "Rp", with: "")
    //         .replacingOccurrences(of: " ", with: "")
    //         .replacingOccurrences(of: ".", with: "") // Remove existing thousand separators
    //         .replacingOccurrences(of: ",", with: ".") // Convert decimal comma to dot if needed
        
    //     // Extract number using regex
    //     let pattern = "[0-9]+\\.?[0-9]*"
    //     if let range = cleanedString.range(of: pattern, options: .regularExpression) {
    //         let numberString = String(cleanedString[range])
    //         return Double(numberString)
    //     }
        
    //     return nil
    // }
}
