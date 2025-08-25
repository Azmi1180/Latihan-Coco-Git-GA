import UIKit
final class HomeActivityCell: UICollectionViewCell {

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
        font: .jakartaSans(forTextStyle: .footnote, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )

    private let areaLabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2

    )

    private let priceLabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 1
    )
    private let areaIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(weight: .medium) // Or .semibold
        let image = CocoIcon.icActivityAreaIcon.image.withConfiguration(config)
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private let familyFriendlyBadgeView = FamilyFriendlyBadgeView() // New badge view

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
        areaLabel.attributedText = nil
        priceLabel.attributedText = nil
        familyFriendlyBadgeView.isHidden = true // Hide badge on reuse
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }

    // MARK: - Configure
    func configureCell(_ dataModel: HomeActivityCellDataModel) {
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

        // Configure areaLabel with line height adjustment
        let areaLabelText = dataModel.area
        let areaLabelParagraphStyle = NSMutableParagraphStyle()
        areaLabelParagraphStyle.lineHeightMultiple = 1.1 // Adjust as needed
        let areaLabelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.jakartaSans(forTextStyle: .footnote, weight: .medium),
            .foregroundColor: Token.additionalColorsBlack,
            .paragraphStyle: areaLabelParagraphStyle
        ]
        areaLabel.attributedText = NSAttributedString(string: areaLabelText, attributes: areaLabelAttributes)

        let formattedPrice = formatToIndonesianCurrency(price: dataModel.priceText)
        let attributedString = NSMutableAttributedString(
            string: formattedPrice,
            attributes: [
                .font : UIFont.jakartaSans(forTextStyle: .footnote, weight: .bold),
                .foregroundColor : Token.additionalColorsBlack
            ]
        )
        priceLabel.attributedText = attributedString

        familyFriendlyBadgeView.isHidden = !dataModel.isFamilyFriendly
    }
}

// MARK: - Private Helpers
private extension HomeActivityCell {

    func setupViews() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16

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
        areaStack.spacing = 2
        areaStack.translatesAutoresizingMaskIntoConstraints = false

        // Text stack (name, area, price)
        let stack = UIStackView(arrangedSubviews: [nameLabel, areaStack, priceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        // Add FamilyFriendlyBadgeView
        cardView.addSubview(familyFriendlyBadgeView)
        familyFriendlyBadgeView.translatesAutoresizingMaskIntoConstraints = false

        // Activate all constraints at once for clarity
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 200),
            cardView.heightAnchor.constraint(equalToConstant: 217),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 136),

            stack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8),

            areaIcon.widthAnchor.constraint(equalToConstant: 18),
            areaIcon.heightAnchor.constraint(equalToConstant: 18),

            // FamilyFriendlyBadgeView constraints
            familyFriendlyBadgeView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 4),
            familyFriendlyBadgeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4)
        ])
    }

    func setupCardShadow() {
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15 // More subtle opacity
        cardView.layer.shadowRadius = 6 // Softer diffusion
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4) // Downward offset
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
