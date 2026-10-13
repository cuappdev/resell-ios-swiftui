//
//  MessagesView.swift
//  Resell
//
//  Created by jiwon jeong on 10/12/26.
//

import SwiftUI

struct MessagesView: View {

    // MARK: - Properties

    @State private var viewModel = ViewModel()

    // MARK: - UI

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Messages")
                .font(Constants.Fonts.h1)
                .foregroundStyle(Constants.Colors.black)

            pills

            Spacer()
            emptyState
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Constants.Spacing.horizontalPadding)
        .padding(.top, 16)
        .background(Constants.Colors.white)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var pills: some View {
        HStack(spacing: 12) {
            ForEach(ViewModel.Tab.allCases) { tab in
                pill(tab)
            }
        }
    }

    private func pill(_ tab: ViewModel.Tab) -> some View {
        let isSelected = viewModel.selectedTab == tab
        return Button {
            viewModel.selectedTab = tab
        } label: {
            Text(tab.rawValue)
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.black)
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .overlay {
                    if isSelected {
                        Capsule().strokeBorder(Constants.Colors.resellGradient, lineWidth: 1.5)
                    }
                }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("No messages with sellers yet")
                .font(Constants.Fonts.h2)
                .foregroundStyle(Constants.Colors.black)
                .multilineTextAlignment(.center)

            Text("When you contact a seller, you'll see your messages here")
                .font(Constants.Fonts.body1)
                .foregroundStyle(Constants.Colors.secondaryGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        MessagesView()
    }
}
