//
//  HomeFormScheduleViewModelContract.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation
import SwiftUI

protocol HomeFormScheduleViewModelDelegate: AnyObject {
    func notifyFormScheduleDidNavigateToCheckout(with response: CreateBookingResponse)
}

protocol HomeFormScheduleViewModelAction: AnyObject {
    func setupView(
        calendarViewModel: HomeSearchBarViewModel,
        paxInputViewModel: HomeSearchBarViewModel,
        departureTimeViewModel: HomeSearchBarViewModel
    )
    func configureView(data: HomeFormScheduleViewData)
    func showCalendarOption()
}

protocol HomeFormScheduleViewModelProtocol: AnyObject {
    var delegate: HomeFormScheduleViewModelDelegate? { get set }
    var actionDelegate: HomeFormScheduleViewModelAction? { get set }

    func onViewDidLoad()
    func onCalendarDidChoose(date: Date)
    func onDepartureTimeDidChoose(time: String)
    func onCheckout()
}
