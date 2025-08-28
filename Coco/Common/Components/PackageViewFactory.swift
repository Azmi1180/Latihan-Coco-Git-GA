
//
//  PackageViewFactory.swift
//  Coco
//
//  Created by Reynard Hansel on 07/07/25.
//

import Foundation
import UIKit

class PackageViewFactory {
    static func createPackageView(data: ActivityDetailDataModel.Package, chooseButtonAction: ((Int) -> Void)?) -> UIView {
        let mainStackView = createStackView(spacing: 16)
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .headline, weight: .bold),
            textColor: Token.additionalColorsBlack
        )
        titleLabel.text = data.name
        
        let tagsStackView = createStackView(spacing: 8, axis: .horizontal)
       tagsStackView.addArrangedSubview(createTagView(text: data.pax, icon: UIImage(systemName: "person")))
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
        
        let action: UIAction = UIAction { _ in
            chooseButtonAction?(data.id)
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

    private static func createTagView(text: String, icon: UIImage? = nil) -> UIView {
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
    
    private static func createDottedDivider() -> UIView {
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
    
    private static func extractNumberFromPrice(_ priceString: String) -> Double? {
        let cleanedString = priceString
            .replacingOccurrences(of: "Rp", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        return Double(cleanedString)
    }
    
    private static func createStackView(
        spacing: CGFloat,
        axis: NSLayoutConstraint.Axis = .vertical
    ) -> UIStackView {
        let stackView: UIStackView = UIStackView()
        stackView.spacing = spacing
        stackView.axis = axis

        return stackView
    }
}
