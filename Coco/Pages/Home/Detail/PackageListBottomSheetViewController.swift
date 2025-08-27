
//
//  PackageListBottomSheetViewController.swift
//  Coco
//
//  Created by Reynard Hansel on 07/07/25.
//

import UIKit

protocol PackageCellDelegate: AnyObject {
    func didTapChoosePackage(with packageId: Int)
}

class PackageListBottomSheetViewController: UIViewController {
    
    private let packages: [ActivityDetailDataModel.Package]
    weak var delegate: PackageCellDelegate?
    
    init(packages: [ActivityDetailDataModel.Package]) {
        self.packages = packages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
    }
    
    private func setupTableView() {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PackageCell.self, forCellReuseIdentifier: PackageCell.identifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200 // Provide a reasonable estimate
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension PackageListBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PackageCell.identifier, for: indexPath) as? PackageCell else { return UITableViewCell() }
        let package = packages[indexPath.row]
        cell.configure(with: package)
        cell.delegate = self
        return cell
    }
}

extension PackageListBottomSheetViewController: PackageCellDelegate {
    func didTapChoosePackage(with packageId: Int) {
        // Pass the tap event to the ActivityDetailViewController's delegate
        // This will likely be the ActivityDetailViewController itself
        if let presentingVC = presentingViewController as? ActivityDetailViewController {
            presentingVC.notifyPackagesDetailDidTap(with: packageId)
            dismiss(animated: true, completion: nil)
        }
    }
}

class PackageCell: UITableViewCell {
    static let identifier = "PackageCell"
    weak var delegate: PackageCellDelegate?
    private var packageId: Int? // To store the package ID for the delegate call

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(edges: 16.0)
        stackView.layer.cornerRadius = 16.0
        stackView.layer.borderWidth = 1.5
        stackView.layer.borderColor = Token.grayscale40.cgColor
        stackView.backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .headline, weight: .bold)
        label.textColor = Token.additionalColorsBlack
        return label
    }()

    private lazy var tagsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()

    private lazy var divider: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    private lazy var footerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()

    private lazy var priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private lazy var startFromLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .caption1, weight: .regular)
        label.textColor = Token.grayscale70
        label.text = "Start from"
        return label
    }()

    private lazy var priceLabel: UILabel = UILabel()

    private lazy var chooseButton: UIButton = {
        let button = UIButton()
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
        button.configuration = config
        button.addTarget(self, action: #selector(didTapChooseButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 120).isActive = true
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(tagsStackView)
        mainStackView.addArrangedSubview(divider)
        mainStackView.addArrangedSubview(footerStackView)

        priceStackView.addArrangedSubview(startFromLabel)
        priceStackView.addArrangedSubview(priceLabel)

        footerStackView.addArrangedSubview(priceStackView)
        footerStackView.addArrangedSubview(chooseButton)
        
        // Add dotted divider drawing
        DispatchQueue.main.async {
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = Token.grayscale40.cgColor
            shapeLayer.lineWidth = 1
            shapeLayer.lineDashPattern = [4, 4] 
            
            let path = CGMutablePath()
            path.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: self.divider.frame.width, y: 0)])
            shapeLayer.path = path
            self.divider.layer.addSublayer(shapeLayer)
        }
    }

    func configure(with package: ActivityDetailDataModel.Package) {
        packageId = package.id
        titleLabel.text = package.name
        
        // Clear existing tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add new tags
        tagsStackView.addArrangedSubview(createTagView(text: package.pax, icon: UIImage(systemName: "person")))
        tagsStackView.addArrangedSubview(createTagView(text: package.ageRange))
        tagsStackView.addArrangedSubview(UIView()) // Spacer

        // Format price
        let formattedPrice: String
        if let priceNumber = extractNumberFromPrice(package.price) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale(identifier: "id_ID") 
            formatter.groupingSeparator = "."
            formatter.usesGroupingSeparator = true
            formatter.maximumFractionDigits = 0
            
            if let formattedNumber = formatter.string(from: NSNumber(value: priceNumber)) {
                formattedPrice = "Rp \(formattedNumber)"
            } else {
                formattedPrice = package.price
            }
        } else {
            formattedPrice = package.price
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
    }

    @objc private func didTapChooseButton() {
        if let packageId = packageId {
            delegate?.didTapChoosePackage(with: packageId)
        }
    }

    private func createTagView(text: String, icon: UIImage? = nil) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 6, left: 10, bottom: 6, right: 10)
        stackView.backgroundColor = Token.grayscale20
        stackView.layer.cornerRadius = 12
        
        if let icon = icon {
            let imageView = UIImageView(image: icon)
            imageView.tintColor = Token.grayscale70
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
            stackView.addArrangedSubview(imageView)
        }
        
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .caption1, weight: .medium)
        label.textColor = Token.grayscale70
        label.text = text
        stackView.addArrangedSubview(label)
        
        return stackView
    }
    
    private func extractNumberFromPrice(_ priceString: String) -> Double? {
        let cleanedString = priceString
            .replacingOccurrences(of: "Rp", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        return Double(cleanedString)
    }
}
