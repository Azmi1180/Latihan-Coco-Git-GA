//
//  HomeFormScheduleViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation
import SwiftUI

struct HomeFormScheduleViewModelInput {
    let package: ActivityDetailDataModel
    let selectedPackageId: Int
}

final class HomeFormScheduleViewModel {
    weak var delegate: (any HomeFormScheduleViewModelDelegate)?
    weak var actionDelegate: (any HomeFormScheduleViewModelAction)?

    @Published var isDepartureTimeDropdownVisible: Bool = false

    init(input: HomeFormScheduleViewModelInput, fetcher: CreateBookingFetcherProtocol = CreateBookingFetcher()) {
        self.input = input
        self.fetcher = fetcher
    }

    private let input: HomeFormScheduleViewModelInput
    private lazy var calendarInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Select Date",
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icCalendarIcon.image,
            didTap: { [weak self] in
                self?.actionDelegate?.showCalendarOption()
            }
        ),
        isTypeAble: false,
        delegate: self,
        behavior: .fixed,
        isRequired: true
    )
    private lazy var paxInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Participants",
        currentTypedText: "",
        trailingIcon: nil,
        isTypeAble: true,
        delegate: self,
        isRequired: true
    )
    private lazy var departureTimeViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Select time",
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icChevronDown.image,
            didTap: { [weak self] in
                self?.isDepartureTimeDropdownVisible.toggle()
            }
        ),
        isTypeAble: false,
        delegate: self,
        behavior: .fixed,
        isRequired: true
    )
    private var chosenDateInput: Date? {
        didSet {
            guard let chosenDateInput else { return }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            calendarInputViewModel.currentTypedText = dateFormatter.string(from: chosenDateInput)
        }
    }
    private var departureTime: String? {
        didSet {
            departureTimeViewModel.currentTypedText = departureTime ?? ""
        }
    }
    private let fetcher: CreateBookingFetcherProtocol
}

extension HomeFormScheduleViewModel: HomeFormScheduleViewModelProtocol {
    func onDepartureTimeDidChoose(time: String) {
        self.departureTime = time
        self.isDepartureTimeDropdownVisible = false
    }
    func onViewDidLoad() {
        actionDelegate?.setupView(
            calendarViewModel: calendarInputViewModel,
            paxInputViewModel: paxInputViewModel,
            departureTimeViewModel: departureTimeViewModel
        )
        let data: HomeFormScheduleViewData = HomeFormScheduleViewData(
            activityName: input.package.title,
            packageName: input.package.availablePackages.content.first { $0.id == input.selectedPackageId }?.name ?? "",
            participantRange: input.package.availablePackages.content.first{ $0.id == input.selectedPackageId }?.pax ?? "",
            location: input.package.location,
            ageRange: "5-65",
            providerName: input.package.providerDetail.content.name,
            price: input.package.availablePackages.content.first{ $0.id == input.selectedPackageId }?.price ?? ""
        )
        actionDelegate?.configureView(data: data)
    }

    func onCalendarDidChoose(date: Date) {
        chosenDateInput = date
    }

    func onCheckout() {
        Task {
            do {
                let request: CreateBookingSpec = CreateBookingSpec(
                    packageId: input.selectedPackageId,
                    bookingDate: chosenDateInput ?? Date(),
                    participants: Int(paxInputViewModel.currentTypedText) ?? 1,
                    userId: UserDefaults.standard.value(forKey: "user-id") as? String ?? ""
                )

                let response: CreateBookingResponse = try await fetcher.createBooking(request: request)
                delegate?.notifyFormScheduleDidNavigateToCheckout(with: response)
            }
            catch {

            }
        }
    }
}

extension HomeFormScheduleViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        if viewModel === calendarInputViewModel {
            actionDelegate?.showCalendarOption()
        }
        else if viewModel === paxInputViewModel {

        }
        else if viewModel === departureTimeViewModel {
            isDepartureTimeDropdownVisible.toggle()
        }
    }
    
    func homeSearchBarDidTapForNavigation() {
        // This method is called when isTypeAble is false, which is the case for calendarInputViewModel
        // So, we should trigger the calendar option here.
        actionDelegate?.showCalendarOption()
    }
}

private extension HomeFormScheduleViewModel {
    func openCalendar() {

    }
    
    func showDepartureTimePicker() {
        
    }
}
