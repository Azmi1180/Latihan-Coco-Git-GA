//
//  HomeFormScheduleView.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation
import UIKit

struct HomeFormScheduleViewData {
    let activityName: String
    let packageName: String
    let participantRange: String
    let location: String
    let ageRange: String
    let providerName: String
    let price: String
}


final class HomeFormScheduleView: UIView {
    private var pricePerPax: Double = 0.0
    var onBookNowTapped: (() -> Void)? // New property
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(data: HomeFormScheduleViewData) {
        activityNameLabel.text = data.activityName
        locationLabel.text = data.location
        activityPackageNameLabel.text = data.packageName
        participantRangeLabel.text = data.participantRange
        ageRangeLabel.text = "Ages \(data.ageRange)"
        providerNameLabel.text = data.providerName
        priceLabel.text = data.price
        
        // Parse price to store as Double
        let cleanedPriceString = data.price
            .replacingOccurrences(of: "Rp", with: "") // Remove "Rp"
            .replacingOccurrences(of: ".", with: "") // Remove thousands separator (if it's a dot)
            .replacingOccurrences(of: ",", with: ".") // Replace comma decimal with dot decimal (if applicable)
            .trimmingCharacters(in: .whitespacesAndNewlines) // Remove leading/trailing spaces
        if let priceDouble = Double(cleanedPriceString) {
            self.pricePerPax = priceDouble
        } else {
            print("configureView: Warning: Could not parse price string '\(data.price)' (cleaned to '\(cleanedPriceString)') to Double. pricePerPax remains \(self.pricePerPax).") //
            
            self.pricePerPax = 0.0
        }
    }
    
    
    func updateTotalPrice(participantCount: Int) {
        let totalPrice = Double(participantCount) * pricePerPax
        priceValueLabel.text = "Rp \(String(format: "%.0f", totalPrice))" // Format as currency, no decimals
    }
    
    func addInputView(from view: UIView) {
        inputContainerView.subviews.forEach { $0.removeFromSuperview() }
        inputContainerView.addSubviewAndLayout(view)
    }
    
    private lazy var activityDetailCard: UIView = createActivityDetailCard()
    
    private lazy var activityNameLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .title2, weight: .bold), textColor: Token.additionalColorsBlack, numberOfLines: 0)
    private lazy var locationLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .footnote, weight: .medium), textColor: Token.additionalColorsBlack, numberOfLines: 2)
    private lazy var activityPackageNameLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .callout, weight: .semibold), textColor: Token.additionalColorsBlack, numberOfLines: 0)
    private lazy var participantRangeLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .footnote, weight: .medium), textColor: Token.grayscale90, numberOfLines: 0)
    private lazy var ageRangeLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .footnote, weight: .medium), textColor: Token.grayscale90, numberOfLines: 0)
    private lazy var providerNameLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .footnote, weight: .medium), textColor: Token.additionalColorsBlack, numberOfLines: 0)
    lazy var inputContainerView: UIView = UIView()
    private lazy var priceLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .title2, weight: .bold), textColor: Token.additionalColorsBlack, numberOfLines: 0)
    private lazy var scrollView: UIScrollView = UIScrollView()
    private lazy var contentView: UIView = UIView()
    private var priceTitleLabel: UILabel = UILabel()
    private var priceSubtitleLabel: UILabel = UILabel()
    private lazy var totalPriceLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .footnote, weight: .medium), textColor: Token.grayscale60, numberOfLines: 1)
    private lazy var priceValueLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .title2, weight: .bold), textColor: Token.mainColorPrimary, numberOfLines: 1)
    private lazy var payDuringTripLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .footnote, weight: .medium), textColor: Token.grayscale70, numberOfLines: 1)
    private lazy var moneyIconImageView: UIImageView = UIImageView(image: CocoIcon.icMoney.image)
    private lazy var greenBannerView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.additionalToColorsGreen
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        
        let label = UILabel()
        label.text = "Make sure your details are correct before booking."
        label.font = .jakartaSans(forTextStyle: .footnote, weight: .medium)
        label.textColor = Token.additionalColorsBlack
        label.textAlignment = .center
        label.numberOfLines = 1
        
        view.addSubview(label)
        label.layout {
            $0.centerX(to: view.centerXAnchor)
            $0.centerY(to: view.centerYAnchor)
            $0.leading(to: view.leadingAnchor, constant: 16)
            $0.trailing(to: view.trailingAnchor, constant: -16)
        }
        
        return view
    }()
    private lazy var bottomContainerView: UIView = UIView()
    private lazy var bookNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Book Now", for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .headline, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Token.mainColorPrimary
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.layout {
            $0.height(52)
            $0.width(140)
        }
        button.addTarget(self, action: #selector(bookNowButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func bookNowButtonTapped() {
        onBookNowTapped?()
    }
    
    
}


private extension HomeFormScheduleView {
    func setupView() {
        backgroundColor = Token.additionalColorsWhite
        
        addSubview(scrollView)
        addSubview(greenBannerView)
        addSubview(bottomContainerView)
        scrollView.addSubview(contentView)
        scrollView.layout {
            $0.top(to: self.safeAreaLayoutGuide.topAnchor)
                .leading(to: self.leadingAnchor)
                .trailing(to: self.trailingAnchor)
                .bottom(to: greenBannerView.topAnchor, constant: -8)
        }
        
        contentView.layout {
            $0.top(to: scrollView.topAnchor)
                .leading(to: scrollView.leadingAnchor)
                .trailing(to: scrollView.trailingAnchor)
                .bottom(to: scrollView.bottomAnchor)
        }
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Layout button fixed di bawah
        
        greenBannerView.layout {
            $0.top(to: scrollView.bottomAnchor)
                .leading(to: self.leadingAnchor)
                .trailing(to: self.trailingAnchor)
                .height(34)
                .bottom(to: bottomContainerView.topAnchor) // nempel ke atas bottom container
        }
        bottomContainerView.backgroundColor = Token.additionalColorsWhite // Keep the current background color
        bottomContainerView.layout{
            $0.leading(to: self.leadingAnchor)
                .top(to: greenBannerView.bottomAnchor, constant: 0)
                .trailing(to: self.trailingAnchor)
                .bottom(to: self.bottomAnchor, constant: 0)
                .height(140)
        }
        
        // New components for bottomContainerView
        moneyIconImageView.layout { $0.size(21) }
        let payDuringTripHStack = UIStackView(arrangedSubviews: [moneyIconImageView, payDuringTripLabel])
        payDuringTripHStack.axis = .horizontal
        payDuringTripHStack.spacing = 4
        payDuringTripHStack.alignment = .center
        
        totalPriceLabel.text = "Total Price"
        priceValueLabel.text = "Rp 0" // Placeholder
        payDuringTripLabel.text = "Pay During Trip" // Set text for this label
        let priceDetailsVStack = UIStackView(arrangedSubviews: [totalPriceLabel, priceValueLabel, payDuringTripHStack])
        priceDetailsVStack.axis = .vertical
        priceDetailsVStack.spacing = 4
        priceDetailsVStack.alignment = .leading
        
        let spacerView = UIView()
        let mainHStack = UIStackView(arrangedSubviews: [priceDetailsVStack, spacerView, bookNowButton])
        mainHStack.axis = .horizontal
        mainHStack.alignment = .center
        mainHStack.distribution = .fill
        mainHStack.spacing = 8
        
        bottomContainerView.addSubview(mainHStack)
        mainHStack.layout {
            $0.top(to: bottomContainerView.topAnchor, constant: 16)
            $0.leading(to: bottomContainerView.leadingAnchor, constant: 27)
            $0.trailing(to: bottomContainerView.trailingAnchor, constant: -27)
            $0.bottom(to: bottomContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        }
        
        let priceCardView: UIView  = createPriceCardView()
        let activityDetailView: UIView = createActivityDetailCard()
        
        contentView.addSubviews([activityDetailView, inputContainerView, priceCardView])
        
        activityDetailView.layout {
            $0.top(to: contentView.topAnchor, constant: 10)
                .leading(to: contentView.leadingAnchor, constant: 27.0)
                .trailing(to: contentView.trailingAnchor, constant: -27.0)
        }
        
        inputContainerView.layout {
            $0.top(to: activityDetailView.bottomAnchor, constant: 20)
                .leading(to: contentView.leadingAnchor, constant: 27.0)
                .trailing(to: contentView.trailingAnchor, constant: -27.0)
                .bottom(to: priceCardView.topAnchor, constant: -16)
        }
        
        priceCardView.layout {
            $0.leading(to: contentView.leadingAnchor, constant: 27.0)
                .trailing(to: contentView.trailingAnchor, constant: -27.0)
                .bottom(to: contentView.bottomAnchor, constant: -16)
        }
        
    }
    
    func createActivityDetailCard() -> UIView {
        let locationIcon = UIImageView(image: CocoIcon.icPinPointBlue.image)
        locationIcon.layout { $0.size(20.0) }
        let verifiedIcon = UIImageView(image: CocoIcon.icVerified.image)
        locationIcon.layout { $0.size(20.0) }
        
        let locationStack = UIStackView(arrangedSubviews: [locationIcon, locationLabel])
        locationStack.axis = .horizontal
        locationStack.spacing = 4.0
        locationStack.alignment = .center
        // horizontal stack untuk icon verify dan provider name
        let providerStack = UIStackView(arrangedSubviews: [verifiedIcon, providerNameLabel])
        providerStack.axis = .horizontal
        providerStack.spacing = 4.0
        providerStack.alignment = .center
        
        // horizontal Stack untuk label min-max participant dan age
        let horizontalStack = UIStackView(arrangedSubviews:
                                            [createCapsuleLabel(icon: CocoIcon.icPerson.image, label: participantRangeLabel),
                                             createCapsuleLabel(icon: nil, label: ageRangeLabel)
                                            ])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 8
        let contentVStack = UIStackView(arrangedSubviews: [
            activityNameLabel,
            locationStack,
            providerStack,
            activityPackageNameLabel,
            horizontalStack
        ])
        contentVStack.axis = .vertical
        contentVStack.spacing = 8.0
        contentVStack.alignment = .leading
        
        let cardContainer = UIView()
        cardContainer.backgroundColor = Token.additionalColorsWhite
        cardContainer.layer.cornerRadius = 16.0
        cardContainer.layer.borderWidth = 1.0
        cardContainer.layer.borderColor = Token.grayscale40.cgColor
        cardContainer.clipsToBounds = true
        cardContainer.addSubview(contentVStack)
        contentVStack.layout {
            $0.top(to: cardContainer.topAnchor, constant: 16.0)
                .leading(to: cardContainer.leadingAnchor, constant: 16.0)
                .trailing(to: cardContainer.trailingAnchor, constant: -16.0)
                .bottom(to: cardContainer.bottomAnchor, constant: -16.0)
        }
        
        cardContainer.layout {
            $0.width(335.0)
        }
        
        return cardContainer
    }
    
    private func createPriceCardView()-> UIView{
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.borderWidth = 1.0
        cardView.layer.borderColor = Token.grayscale40.cgColor
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        priceTitleLabel.text = "Price"
        priceTitleLabel.font = .jakartaSans(forTextStyle: .footnote, weight: .medium)
        priceTitleLabel.textColor = Token.grayscale60
        
        priceSubtitleLabel.text = "Prices vary by date"
        priceSubtitleLabel.font = .jakartaSans(forTextStyle: .caption2, weight: .medium)
        priceSubtitleLabel.textColor = Token.mainColorPrimary
        
        let priceVStack = UIStackView(arrangedSubviews: [priceTitleLabel, priceSubtitleLabel])
        priceVStack.axis = .vertical
        priceVStack.spacing = 2
        priceVStack.alignment = .leading
        
        let spacerView = UIView()
        let paxLabel: UILabel = UILabel(font: .jakartaSans(forTextStyle: .callout, weight: .medium), textColor: Token.grayscale70, numberOfLines: 0)
        paxLabel.text = "  /Pax"
        
        let hStack = UIStackView(arrangedSubviews: [priceVStack, spacerView, priceLabel, paxLabel])
        hStack.axis = .horizontal
        hStack.alignment = .center
        cardView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 66),
            
            hStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            hStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
        
        return cardView
    }

    private func createCapsuleLabel(icon: UIImage?, label: UILabel) -> UIView {
        let hstack: UIStackView

        if let iconImage = icon {
            let icon = UIImageView(image: iconImage)
            icon.layout { $0.size(16.0) }
            hstack = UIStackView(arrangedSubviews: [icon, label])
            hstack.axis = .horizontal
            hstack.spacing = 2
            hstack.alignment = .center
        } else {
            hstack = UIStackView(arrangedSubviews: [label])
            hstack.axis = .horizontal
            hstack.alignment = .center
        }
        
        let containerView = UIView()
        containerView.backgroundColor = Token.grayscale20 
        containerView.layer.cornerRadius = 13.0
        containerView.clipsToBounds = true
        
        containerView.addSubview(hstack)
        hstack.layout {
            $0.top(to: containerView.topAnchor, constant: 4)
                .bottom(to: containerView.bottomAnchor, constant: -4)
                .leading(to: containerView.leadingAnchor, constant: 8)
                .trailing(to: containerView.trailingAnchor, constant: -8) //
        }
        
        containerView.layout {
            $0.height(26) 
        }
        return containerView
    }
}


