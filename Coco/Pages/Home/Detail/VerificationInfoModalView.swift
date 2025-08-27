import Foundation
import UIKit

final class VerificationInfoModalView: UIView {
    
    var onClose: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        // Main modal container
        let modalView = UIView()
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 16
        
        addSubview(modalView)
        modalView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modalView.centerXAnchor.constraint(equalTo: centerXAnchor),
            modalView.centerYAnchor.constraint(equalTo: centerYAnchor),
            modalView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            modalView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        // --- Header ---
        let titleLabel = UILabel()
        titleLabel.text = "Verified Provider"
        // Using system font as a fallback for .jakartaSans, which might be a custom extension.
        // If you have the custom font helper, you can use:
        // titleLabel.font = .jakartaSans(forTextStyle: .title3, weight: .bold)
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.distribution = .equalSpacing

        let separatorView = UIView()
        separatorView.backgroundColor = .systemGray5
        
        // --- Body Content ---
        let firstParagraphLabel = createParagraphLabel(
            fullText: "1. The Verified Provider badge is awarded to snorkeling operators holding an official CHSE (Cleanliness, Health, Safety, and Environmental Sustainability) certification. This certification is valid for 3 years and ensures the provider maintains trusted standards of hygiene, safety, and environmental care.",
            boldParts: ["official CHSE (Cleanliness, Health, Safety, and Environmental Sustainability) certification"]
        )
        
        // NOTE: Replace "chse_badge" with the actual name of your image asset.
        let badgeImageView = UIImageView(image: UIImage(named: "chse"))
        badgeImageView.contentMode = .scaleAspectFit
        badgeImageView.layer.cornerRadius = 12
        badgeImageView.clipsToBounds = true
        
        let secondParagraphLabel = createParagraphLabel(
            fullText: "2. Trips are led by certified guides with professional credentials from recognized organizations such as POSSI, PADI, SSI, NAUI, or ADS-I, ensuring a safe and expertly guided experience.",
            boldParts: ["led by certified guides"]
        )
        
        let finalParagraphLabel = UILabel()
        finalParagraphLabel.text = "The badge guarantees you are booking with a reliable operator that prioritizes your safety, comfort, and the environment."
        // Using system font as a fallback
        finalParagraphLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        finalParagraphLabel.textColor = .darkGray
        finalParagraphLabel.numberOfLines = 0
        
        // --- Main StackView to hold all elements ---
        let mainStackView = UIStackView(arrangedSubviews: [
            titleStackView,
            separatorView,
            firstParagraphLabel,
            badgeImageView,
            secondParagraphLabel,
            finalParagraphLabel
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 24 // Default spacing
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Custom spacing to match the design
        mainStackView.setCustomSpacing(16, after: titleStackView)
        mainStackView.setCustomSpacing(16, after: secondParagraphLabel)
        
        modalView.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            badgeImageView.heightAnchor.constraint(equalToConstant: 85), // Adjust height as needed
            
            mainStackView.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: modalView.bottomAnchor, constant: -20)
        ])
    }
    
    /// Creates a label with specific parts of the text bolded.
    private func createParagraphLabel(fullText: String, boldParts: [String]) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        
        // Using system font as a fallback for .jakartaSans
        let regularFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        let boldFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [
            .font: regularFont,
            .foregroundColor: UIColor.darkGray
        ])
        
        for boldPart in boldParts {
            let boldRange = (fullText as NSString).range(of: boldPart)
            if boldRange.location != NSNotFound {
                attributedString.addAttributes([.font: boldFont, .foregroundColor: UIColor.black], range: boldRange)
            }
        }
        
        label.attributedText = attributedString
        return label
    }
    
    @objc private func closeButtonTapped() {
        onClose?()
    }
}
