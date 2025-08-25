//
//  HomeLoadingView.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import SwiftUI

struct HomeLoadingView: View {
    @ObservedObject var state: HomeLoadingState
    @State var currentTypedText: String = ""

    var body: some View {
        Text("Just a moment, we’re preparing")
            .font(
                .jakartaSans(
                    forTextStyle: .title2,
                    weight: .bold
                )
            )

        VStack(alignment: .center, spacing: 32) {
            Text("the best trip for you 🤿")
                .font(
                    .jakartaSans(
                        forTextStyle: .title2,
                        weight: .bold
                    )
                )
            CocoLoadingBar(percentage: state.percentageV)
        }
        .padding(16.0)
    }
}
