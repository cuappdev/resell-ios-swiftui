//
//  LabeledTextField.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

/// A labeled text input that supports single- and multi-line entry with an optional character cap.
struct LabeledTextField: View {

    // MARK: - Properties

    let label: String
    var maxCharacters: Int?
    var frameHeight: CGFloat = 40
    var isMultiLine: Bool = false
    var placeholder: String = ""

    @Binding var text: String

    // MARK: - UI

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.black)

            if isMultiLine {
                multiLineField
            } else {
                singleLineField
            }
        }
    }

    private var singleLineField: some View {
        TextField(placeholder, text: $text)
            .font(Constants.Fonts.body2)
            .foregroundStyle(Constants.Colors.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(height: frameHeight)
            .background(Constants.Colors.wash)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onChange(of: text) { enforceCharacterLimit() }
            .onSubmit { UIApplication.shared.endEditing() }
    }

    private var multiLineField: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(Constants.Fonts.body2)
                    .foregroundStyle(Constants.Colors.secondaryGray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }

            TextEditor(text: $text)
                .font(Constants.Fonts.body2)
                .foregroundStyle(Constants.Colors.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .scrollContentBackground(.hidden)
                .background(Constants.Colors.wash)
                .cornerRadius(10)
                .frame(height: frameHeight)
                .onChange(of: text) { enforceCharacterLimit() }
        }
    }

    private func enforceCharacterLimit() {
        guard let maxCharacters, text.count > maxCharacters else { return }
        text = String(text.prefix(maxCharacters))
    }
}
