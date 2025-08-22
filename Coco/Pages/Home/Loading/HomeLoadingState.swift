//
//  HomeLoadingState.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import SwiftUI

final class HomeLoadingState: ObservableObject {
    // for view usage only
    @Published var percentageV: CGFloat = 0
    var percentage: CGFloat {
        get { percentageV }
        set { percentageV = min(max(newValue, 0), 100) }
    }
}
