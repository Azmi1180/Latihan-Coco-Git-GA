import UIKit

final class EmptyStateView: UIView {

    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = "No trips showing up here today."
        label.textColor = Token.grayscale80
        label.textAlignment = .center
        label.font = UIFont.jakartaSans(size: 16, weight: .bold)
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "islandIcon") // Assuming 'islandIcon' is in Assets.xcassets
        imageView.tintColor = Token.grayscale80
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Why not explore other trips for now? 👀"
        label.textColor = Token.additionalColorsBlack
        label.textAlignment = .center
        label.font = UIFont.jakartaSans(size: 12, weight: .semibold)
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
        addSubview(topLabel)
        addSubview(imageView)
        addSubview(bottomLabel)

        topLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            topLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -16),
            topLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            topLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 123),
            imageView.heightAnchor.constraint(equalToConstant: 123),

            bottomLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            bottomLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            bottomLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}