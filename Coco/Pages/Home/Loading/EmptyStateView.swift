import UIKit

final class EmptyStateView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        // ✅ CHANGED: Increased spacing from 16 to 24 for a more spread-out look.
        stackView.spacing = 24
        return stackView
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = "We couldn't find any trips"
        label.textColor = .systemGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "islandIcon")
        imageView.tintColor = .systemGray4
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Change keywords or filters to discover more"
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        stackView.addArrangedSubview(topLabel)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(bottomLabel)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            // ✅ CHANGED: Added a negative constant to shift the content up,
            // making it appear centered on the whole screen, not just the bottom area.
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),

            imageView.widthAnchor.constraint(equalToConstant: 123),
            imageView.heightAnchor.constraint(equalToConstant: 123),
        ])
    }
}
