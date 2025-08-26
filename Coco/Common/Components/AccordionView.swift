//
//  AccordionView.swift
//  Coco
//
//  Created by Copilot on 26/08/25.
//

import UIKit

class AccordionView: UIView {
    private var title: String
    private var contentView: UIView
    private var isExpanded: Bool = false

    private lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .subheadline, weight: .medium)
        button.setTitleColor(Token.additionalColorsBlack, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        return button
    }()

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)))
        imageView.tintColor = Token.additionalColorsBlack
        return imageView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerStackView, contentView])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleButton, arrowImageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    init(title: String, contentView: UIView) {
        self.title = title
        self.contentView = contentView
        super.init(frame: .zero)
        self.contentView.isHidden = true
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
        contentView.isHidden = !isExpanded
        
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform = self.isExpanded ? .identity : CGAffineTransform(rotationAngle: .pi)
        }
    }
}
