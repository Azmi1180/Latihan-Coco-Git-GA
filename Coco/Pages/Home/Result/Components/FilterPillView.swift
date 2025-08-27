//
//  FilterPillView.swift
//  Coco
//
//  Created by Reynard on 26/08/25.
//

import UIKit

protocol FilterPillViewDelegate: AnyObject {
    func didSelectFilterPill(with id: String)
}

class FilterPillView: UIView {

    weak var delegate: FilterPillViewDelegate?

    private var pills: [FilterPillDataModel] = []
    private var selectedPillId: String?
    
    // MARK: - Style Change: Add a Scroll View
    // This allows the pills to scroll horizontally if they don't fit on the screen.
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // MARK: - Style Change: Set up the scroll view
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // The scroll view fills the entire view
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // The stack view is pinned to the scroll view's content area
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    func configure(with pills: [FilterPillDataModel], selectedPillId: String?) {
        self.pills = pills
        self.selectedPillId = selectedPillId
        updatePills()
    }

    private func updatePills() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // MARK: - Style Change: Define specific colors to match the image
//        let selectedBackgroundColor = UIColor(red: 0.88, green: 0.95, blue: 1.00, alpha: 1.00) // Light Cyan
        let selectedTextColor = Token.mainColorPrimary
        let selectedBorderColor = Token.mainColorPrimary.cgColor
        let deselectedTextColor = UIColor.label
        let deselectedBorderColor = UIColor.systemGray4.cgColor

        for pill in pills {
            let button = PillButton(type: .system) // Using a custom button class for perfect corners
            button.setTitle(pill.title, for: .normal)
            button.tag = pill.hashValue
            button.addTarget(self, action: #selector(pillTapped), for: .touchUpInside)
            
            // MARK: - Style Change: Update font and padding
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.layer.borderWidth = 1

            if pill.id == selectedPillId {
//                button.backgroundColor = selectedBackgroundColor
                button.setTitleColor(selectedTextColor, for: .normal)
                button.layer.borderColor = selectedBorderColor
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(deselectedTextColor, for: .normal)
                button.layer.borderColor = deselectedBorderColor
            }
            stackView.addArrangedSubview(button)
        }
    }

    @objc private func pillTapped(_ sender: UIButton) {
        if let tappedPill = pills.first(where: { $0.hashValue == sender.tag }) {
            delegate?.didSelectFilterPill(with: tappedPill.id)
        }
    }
}

// MARK: - Style Change: Custom Button Subclass
// This helper class ensures the corner radius is always a perfect "pill" shape.
private class PillButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        // This makes the corner radius half the button's height, creating the capsule shape.
        layer.cornerRadius = frame.height / 2
    }
}
