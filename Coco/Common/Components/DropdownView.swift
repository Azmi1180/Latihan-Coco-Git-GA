//
//  DropdownView.swift
//  Coco
//
//  Created by Louise on 26/08/25.
//

import UIKit

class DropdownView: UIView {
    
    private let tableView = UITableView()
    private var options: [String] = []
    private var onSelect: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(options: [String], onSelect: @escaping (String) -> Void) {
        self.options = options
        self.onSelect = onSelect
        self.tableView.reloadData()
    }
    
    private func setupView() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        layer.borderColor = Token.grayscale40.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 8.0
        clipsToBounds = true
    }
}

extension DropdownView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
}

extension DropdownView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(options[indexPath.row])
    }
}
