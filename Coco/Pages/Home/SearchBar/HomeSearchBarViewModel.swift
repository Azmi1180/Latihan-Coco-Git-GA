//
//  HomeSearchBarViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import SwiftUI
import Combine

protocol HomeSearchBarViewModelDelegate: AnyObject {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel)
}

enum SearchBarBehavior {
    case fixed
    case hiddenWhenEmpty
}

enum OutlineState {
    case normal
    case error
}

enum InputType {
    case date
    case numberOfPeople
    case departureTime
    case generic
}

final class HomeSearchBarViewModel: ObservableObject {
    weak var delegate: HomeSearchBarViewModelDelegate?

    @Published var currentTypedText: String = ""
    @Published var trailingIcon: ImageHandler?
    @Published var outlineState: OutlineState = .normal
    let leadingIcon: UIImage?
    let isTypeAble: Bool
    let isRequired: Bool
    let placeholderText: String?
    let behavior: SearchBarBehavior

    private let defaultTrailingIcon: ImageHandler?
    private var cancellables = Set<AnyCancellable>()

    init(
        leadingIcon: UIImage?,
        placeholderText: String?,
        currentTypedText: String,
        trailingIcon: ImageHandler?,
        isTypeAble: Bool,
        delegate: HomeSearchBarViewModelDelegate?,
        behavior: SearchBarBehavior = .hiddenWhenEmpty,
        isRequired: Bool = false
    ) {
        self.leadingIcon = leadingIcon
        self.placeholderText = placeholderText
        self.currentTypedText = currentTypedText
        self.trailingIcon = trailingIcon
        self.isTypeAble = isTypeAble
        self.delegate = delegate
        self.behavior = behavior
        self.isRequired = isRequired
        self.defaultTrailingIcon = trailingIcon

        observeSearchText()
    }

    func onTextFieldFocusDidChange(to newFocus: Bool) {
        guard newFocus else { return }
        delegate?.notifyHomeSearchBarDidTap(isTypeAble: isTypeAble, viewModel: self)
    }

    private func observeSearchText() {
        $currentTypedText
            .sink { [weak self] newText in
                guard let self = self else { return }
                switch self.behavior {
                case .fixed:
                    self.trailingIcon = self.defaultTrailingIcon
                case .hiddenWhenEmpty:
                    if newText.isEmpty {
                        self.trailingIcon = nil
                    } else {
                        self.trailingIcon = self.defaultTrailingIcon
                    }
                }
                if self.isRequired && newText.isEmpty {
                    self.outlineState = .error
                } else {
                    self.outlineState = .normal
                }
            }
            .store(in: &cancellables)
    }
}
