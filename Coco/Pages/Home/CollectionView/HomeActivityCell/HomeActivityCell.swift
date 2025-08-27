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
        numberOfLines: 1
    )

    private let areaLabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2

    )
    private let startFromLabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale60,
        numberOfLines: 1
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
    

    private lazy var familyFriendlyBadgeView = createBadge()// New badge view

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

        let formattedPrice = String.formatToIndonesianCurrency(price: dataModel.priceText)
        let attributedString = NSMutableAttributedString(
            string: formattedPrice,
            attributes: [
                .font : UIFont.jakartaSans(forTextStyle: .footnote, weight: .bold),
                .foregroundColor : Token.additionalColorsBlack
            ]
        )
        priceLabel.attributedText = attributedString
        
        startFromLabel.text = "Start From"

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
        let topStack = UIStackView(arrangedSubviews: [nameLabel, areaStack])
        topStack.axis = .vertical
        topStack.spacing = 0
        topStack.alignment = .leading
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomStack = UIStackView(arrangedSubviews: [startFromLabel, priceLabel])
        bottomStack.axis = .vertical
        bottomStack.spacing = 3
        bottomStack.alignment = .leading
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        
        let stackContainer = UIStackView(arrangedSubviews: [topStack, bottomStack])
        stackContainer.axis = .vertical
        stackContainer.spacing = 8
        stackContainer.alignment = .leading
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stackContainer)

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

            stackContainer.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            stackContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            stackContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            stackContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -4),
            
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
    
    func createBadge() -> UIView {
        let badgeView = UIView()
        badgeView.backgroundColor = Token.additionalToColorsGreen
        badgeView.layer.cornerRadius = 12
        badgeView.layer.masksToBounds = true
        badgeView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            badgeView.widthAnchor.constraint(equalToConstant: 34),
            badgeView.heightAnchor.constraint(equalToConstant: 26)
        ])

        let imageView = UIImageView(image: UIImage(named: "familyIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        badgeView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18)
        ])

        badgeView.isHidden = true // pindahkan ke sini sebelum return
        return badgeView
    }


}
