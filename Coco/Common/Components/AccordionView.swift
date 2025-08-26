//
//  AccordionView.swift
//  Coco
//
//  Created by Copilot on 26/08/25.
//

import UIKit

class AccordionView: UIView {
    private var title: String
    private var content: String
    private var isExpanded: Bool = false

    private lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .subheadline, weight: .bold)
        button.setTitleColor(Token.additionalColorsBlack, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        return button
    }()

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.tintColor = Token.additionalColorsBlack
        return imageView
    }()

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.text = content
        label.numberOfLines = 0
        label.font = .jakartaSans(forTextStyle: .footnote, weight: .regular)
        label.textColor = Token.grayscale70
        label.isHidden = true
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerStackView, contentLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleButton, arrowImageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    init(title: String, content: String) {
        self.title = title
        self.content = content
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func toggle() {
        isExpanded.toggle()
        contentLabel.isHidden = !isExpanded
        
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform = self.isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        }
    }
}
