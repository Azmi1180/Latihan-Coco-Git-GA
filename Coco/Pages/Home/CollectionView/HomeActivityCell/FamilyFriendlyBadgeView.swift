import UIKit

final class FamilyFriendlyBadgeView: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Family-Friendly"
        label.font = .systemFont(ofSize: 9, weight: .bold) // Reduced font size
        label.textColor = .black // Or a suitable contrasting color
        return label
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

        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6), // Internal padding
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12), // Internal padding
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12), // Internal padding
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6) // Internal padding
        ])

        // Set explicit size for the badge
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 100),
            heightAnchor.constraint(equalToConstant: 27)
        ])
    }
}
