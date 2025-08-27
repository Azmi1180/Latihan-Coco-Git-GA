//
//  HomeFormScheduleViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation
import SwiftUI
import UIKit
import Combine

final class HomeFormScheduleViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: HomeFormScheduleViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = thisView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
        title = "Booking Detail"
        
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        
        let closeButton = UIBarButtonItem(image: CocoIcon.icCross.image, style: .plain, target: self, action: #selector(dismissViewController))
        closeButton.tintColor = .black
        navigationItem.leftBarButtonItem = closeButton
        
        // Add divider
        let divider = UIView()
        divider.backgroundColor = Token.grayscale40
        divider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -5),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1.0)
        ])
        
        setupDropdownView()
        observeViewModel()
    }

    @objc private func dismissViewController() {
        dismiss(animated: true)
    }

    private let viewModel: HomeFormScheduleViewModelProtocol
    private let thisView: HomeFormScheduleView = HomeFormScheduleView()
    private let dropdownView = DropdownView()
    
    private func setupDropdownView() {
        view.addSubview(dropdownView)
        dropdownView.translatesAutoresizingMaskIntoConstraints = false
        
        let dropdownHeightConstraint = dropdownView.heightAnchor.constraint(equalToConstant: 120)
        dropdownHeightConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            dropdownView.topAnchor.constraint(equalTo: thisView.inputContainerView.topAnchor, constant: 140),
            dropdownView.leadingAnchor.constraint(equalTo: thisView.inputContainerView.leadingAnchor),
            dropdownView.trailingAnchor.constraint(equalTo: thisView.inputContainerView.trailingAnchor),
            dropdownHeightConstraint
        ])
        dropdownView.configure(options: ["07.00", "10.00", "12.00"]) { [weak self] time in
            self?.viewModel.onDepartureTimeDidChoose(time: time)
        }
        dropdownView.isHidden = true
    }
    
    private func observeViewModel() {
        guard let viewModel = viewModel as? HomeFormScheduleViewModel else { return }
        viewModel.$isDepartureTimeDropdownVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                self?.dropdownView.isHidden = !isVisible
            }
            .store(in: &cancellables)
    }
}

extension HomeFormScheduleViewController: HomeFormScheduleViewModelAction {
    func setupView(
        calendarViewModel: HomeSearchBarViewModel,
        paxInputViewModel: HomeSearchBarViewModel,
        departureTimeViewModel: HomeSearchBarViewModel
    ) {
        let inputVC: UIHostingController = UIHostingController(
            rootView: HomeFormScheduleInputView(
                calendarViewModel: calendarViewModel,
                paxInputViewModel: paxInputViewModel,
                departureTimeViewModel: departureTimeViewModel,
                actionButtonAction: { 
                },
                onPaxCountChanged: { [weak self] count in // Add this closure
                    self?.thisView.updateTotalPrice(participantCount: count)
                }
            )
        )
        addChild(inputVC)
        thisView.addInputView(from: inputVC.view)
        inputVC.didMove(toParent: self)

        // Call updateTotalPrice with initial pax count
        if let initialPaxCount = Int(paxInputViewModel.currentTypedText) {
            thisView.updateTotalPrice(participantCount: initialPaxCount)
        } else {
            thisView.updateTotalPrice(participantCount: 0) // Default to 0 if not parsable
        }

        thisView.onBookNowTapped = { [weak self] in
            self?.viewModel.onCheckout()
        }
    }

    func configureView(data: HomeFormScheduleViewData) {
        thisView.configureView(data: data)
    }

    func showCalendarOption() {
        let calendarVC: CocoCalendarViewController = CocoCalendarViewController()
        calendarVC.delegate = self
        let popup: CocoPopupViewController = CocoPopupViewController(child: calendarVC)
        present(popup, animated: true)
    }
}

extension HomeFormScheduleViewController: CocoCalendarViewControllerDelegate {
    func notifyCalendarDidChooseDate(date: Date?, calendar: CocoCalendarViewController) {
        guard let date: Date else { return }
        viewModel.onCalendarDidChoose(date: date)
    }
}
