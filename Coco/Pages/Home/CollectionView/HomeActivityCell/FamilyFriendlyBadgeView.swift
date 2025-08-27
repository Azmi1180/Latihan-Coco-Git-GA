import UIKit

final class FamilyFriendlyBadgeView: UIView {

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Family-Friendly"
        label.font = .systemFont(ofSize: 9, weight: .bold) // Reduced font size
        label.textColor = .black // Or a suitable contrasting color
        return label
    }()
    
    private let groupIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(weight: .medium) // Or .semibold
        let image = CocoIcon.icFamilyIcon.image.withConfiguration(config)
        let imageView = UIImageView(image: image)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = Token.mainColorLemon // Use the defined color
        layer.cornerRadius = 13.5 // Capsule shape
        clipsToBounds = false // Shadow needs clipsToBounds = false on the view itself

        // Professional Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        
        let vStack: UIStackView = UIStackView(arrangedSubviews: [groupIcon, nameLabel])
        vStack.axis = .horizontal
        vStack.spacing = 4
        vStack.alignment = .center
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            groupIcon.widthAnchor.constraint(equalToConstant: 15),
            groupIcon.heightAnchor.constraint(equalToConstant: 15)
        ])


        // Set explicit size for the badge
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 120),
            heightAnchor.constraint(equalToConstant: 27)
        ])
    }
}
