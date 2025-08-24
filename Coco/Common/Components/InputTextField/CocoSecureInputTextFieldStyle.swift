//
//  CocoSecureInputTextFieldStyle.swift
//  Coco
//
//  Created by Jackie Leonardy on 16/07/25.
//

import Foundation
import SwiftUI

struct CocoSecureInputTextFieldStyle: TextFieldStyle {
    @Binding private var isSecure: Bool
    let leadingIcon: UIImage?
    let placeHolder: String?
    let onFocusedAction: ((Bool) -> Void)?
    init(
        leadingIcon: UIImage?,
        isSecure: Binding<Bool>,
        placeHolder: String?,
        onFocusedAction: ((Bool) -> Void)?
    ) {
        self.leadingIcon = leadingIcon
        _isSecure = isSecure
        self.placeHolder = placeHolder
        self.onFocusedAction = onFocusedAction
    }
    // swiftlint:disable identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(alignment: .center, spacing: 8.0) {
            if let leadingIcon: UIImage {
                Image(uiImage: leadingIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18.0, height: 18.0)
            }
            configuration
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18.0, height: 18.0)
                    .foregroundStyle(.gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 14.0)
        .padding(.horizontal, 16.0)
        .clipShape(Capsule(style: .continuous))
        .overlay(
            Capsule(style: .circular)
                .inset(by: 0.5) // Inset the capsule slightly to prevent clipping
                .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1) // ubah warna dan ketebalan sesuai kebutuhan
         )
    }
}

