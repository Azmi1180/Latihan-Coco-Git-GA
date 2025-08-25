
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
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(with pills: [FilterPillDataModel], selectedPillId: String?) {
        self.pills = pills
        self.selectedPillId = selectedPillId
        updatePills()
    }

    private func updatePills() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for pill in pills {
            let button = UIButton(type: .system)
            button.setTitle(pill.title, for: .normal)
            button.tag = pill.hashValue // Use hashValue as a unique identifier for the button
            button.addTarget(self, action: #selector(pillTapped), for: .touchUpInside)
            button.layer.cornerRadius = 15
            button.layer.borderWidth = 1
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

            if pill.id == selectedPillId {
                button.backgroundColor = .blue // Selected state color
                button.setTitleColor(.white, for: .normal)
                button.layer.borderColor = UIColor.blue.cgColor
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.black, for: .normal)
                button.layer.borderColor = UIColor.gray.cgColor
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
