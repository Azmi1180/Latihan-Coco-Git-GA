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

final class HomeSearchBarViewModel: ObservableObject {
    weak var delegate: HomeSearchBarViewModelDelegate?
    
    @Published var currentTypedText: String = ""
    @Published var trailingIcon: ImageHandler?
    
    let leadingIcon: UIImage?
    let isTypeAble: Bool
    let placeholderText: String
    
    private let defaultTrailingIcon: ImageHandler?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        leadingIcon: UIImage?,
        placeholderText: String,
        currentTypedText: String,
        trailingIcon: ImageHandler?,
        isTypeAble: Bool,
        delegate: HomeSearchBarViewModelDelegate?
    ) {
        self.leadingIcon = leadingIcon
        self.placeholderText = placeholderText
        self.currentTypedText = currentTypedText
        self.trailingIcon = trailingIcon
        self.isTypeAble = isTypeAble
        self.delegate = delegate
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
                if newText.isEmpty {
                    self?.trailingIcon = nil
                } else {
                    self?.trailingIcon = self?.defaultTrailingIcon
                }
            }
            .store(in: &cancellables)
    }
}
