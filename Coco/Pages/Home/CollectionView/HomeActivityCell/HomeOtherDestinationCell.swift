import UIKit
final class HomeOtherDestinationCell: UICollectionViewCell {

    // MARK: - Views
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = false
        return view
    }()

    private let imageView = UIImageView()
    private let nameLabel = UILabel(
        font: .jakartaSans(size: 16, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )

    private let areaLabel = UILabel(
        font: .jakartaSans(size: 14, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )

    private let priceLabel = UILabel(
        font: .jakartaSans(size: 16, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 1
    )
    private let areaIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(weight: .medium) // Or .semibold
        let image = CocoIcon.icActivityAreaIcon.image.withConfiguration(config)
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private let familyFriendlyBadgeView = FamilyFriendlyBadgeView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        nameLabel.setContentHuggingPriority(.required, for: .vertical)
        areaLabel.setContentHuggingPriority(.required, for: .vertical)
        priceLabel.setContentHuggingPriority(.required, for: .vertical)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
        areaLabel.attributedText = nil
        priceLabel.attributedText = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }

    // MARK: - Configure
    func configureCell(_ dataModel: HomeActivityCellDataModel, isFamilyFriendly: Bool) {
        print(dataModel)
        // Cross-fade animation for image loading
        imageView.alpha = 0.0
        imageView.loadImage(from: dataModel.imageUrl) { [weak self] image in
            guard let self = self else { return }
            self.imageView.image = image
            UIView.animate(withDuration: 0.3) {
                self.imageView.alpha = 1.0
            }
        }

        nameLabel.text = dataModel.name
        areaLabel.text = dataModel.area

        let formattedPrice = formatToIndonesianCurrency(price: dataModel.priceText)
        let startFromText = "start from "

        let startFromAttributedString = NSAttributedString(
            string: startFromText,
            attributes: [
                .font: UIFont.jakartaSans(size: 12, weight: .medium),
                .foregroundColor: Token.grayscale80
            ]
        )

        let priceAttributedString = NSAttributedString(
            string: formattedPrice,
            attributes: [
                .font: UIFont.jakartaSans(size: 14, weight: .bold),
                .foregroundColor: Token.additionalColorsBlack
            ]
        )

        let combinedAttributedString = NSMutableAttributedString()
        combinedAttributedString.append(startFromAttributedString)
        combinedAttributedString.append(priceAttributedString)

        priceLabel.attributedText = combinedAttributedString
        familyFriendlyBadgeView.isHidden = !isFamilyFriendly
    }
}

// MARK: - Private Helpers
private extension HomeOtherDestinationCell {

    func setupViews() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12

        setupCardShadow()

        // Image
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(imageView)

        // Area (icon + label)
        let areaStack = UIStackView(arrangedSubviews: [areaIcon, areaLabel])
        areaStack.axis = .horizontal
        areaStack.spacing = 4
        areaStack.translatesAutoresizingMaskIntoConstraints = false

        // Text stack (name, area, price)
        let stack = UIStackView(arrangedSubviews: [nameLabel, areaStack, priceLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        cardView.addSubview(familyFriendlyBadgeView)
        familyFriendlyBadgeView.translatesAutoresizingMaskIntoConstraints = false

        // Activate all constraints at once for clarity
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 390),
            cardView.heightAnchor.constraint(equalToConstant: 356),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 214),

            stack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12),

            areaIcon.widthAnchor.constraint(equalToConstant: 18),
            areaIcon.heightAnchor.constraint(equalToConstant: 18),

            familyFriendlyBadgeView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 4),
            familyFriendlyBadgeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4)
        ])
    }

    func setupCardShadow() {
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 2
        cardView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardView.layer.masksToBounds = false
    }

    func updateShadowPath() {
        let shadowPath = UIBezierPath(
            roundedRect: cardView.bounds,
            cornerRadius: cardView.layer.cornerRadius
        )
        cardView.layer.shadowPath = shadowPath.cgPath
    }

    func formatToIndonesianCurrency(price: String) -> String {
        let numericString = price.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        if let number = Double(numericString) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "Rp "
            formatter.currencyGroupingSeparator = "."
            formatter.currencyDecimalSeparator = ","
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0

            if let formattedString = formatter.string(from: NSNumber(value: number)) {
                return formattedString
            }
        }
        return "Rp \(price)"
    }
}
