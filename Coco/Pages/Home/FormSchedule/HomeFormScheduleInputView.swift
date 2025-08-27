//
//  HomeFormScheduleInputView.swift
//  Coco
//
//  Created by Jackie Leonardy on 23/07/25.
//

import SwiftUI

struct HomeFormScheduleInputView: View {
    @ObservedObject var calendarViewModel: HomeSearchBarViewModel
    @ObservedObject var paxInputViewModel: HomeSearchBarViewModel
    @ObservedObject var departureTimeViewModel: HomeSearchBarViewModel

    var actionButtonAction: () -> Void
    var onPaxCountChanged: (Int) -> Void // New property

    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Date Visit")
                    .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                    .foregroundStyle(Token.grayscale70.toColor())

                HomeSearchBarView(viewModel: calendarViewModel)
            }
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Departure Time")
                    .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                    .foregroundStyle(Token.grayscale70.toColor())
                HomeSearchBarView(viewModel: departureTimeViewModel)
            }
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Number of People")
                    .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                    .foregroundStyle(Token.grayscale70.toColor())
                HomeSearchBarView(viewModel: paxInputViewModel)
            }
            .onChange(of: paxInputViewModel.currentTypedText) { newValue in
                if let count = Int(newValue) {
                    onPaxCountChanged(count)
                } else {
                    onPaxCountChanged(0) // Or handle invalid input as needed
                }
            }
//            Spacer()
//
//            CocoButton(
//                action: actionButtonAction,
//                text: "Book Now",
//                style: .large,
//                type: .primary
//            )
//            .stretch()
        }
    }
}
