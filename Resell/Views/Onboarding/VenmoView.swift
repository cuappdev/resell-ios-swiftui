//
//  VenmoView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

struct VenmoView: View {

    // MARK: - Properties

    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @StateObject private var viewModel = ViewModel()

    // MARK: - UI

    var body: some View {
        VStack(alignment: .center) {
            header

            caption

            LabeledTextField(label: "Venmo Handle", text: $mainViewModel.venmoHandle)
                .padding(.top, Constants.Venmo.fieldTopPadding)

            Spacer()

            continueButton

            skipButton
        }
        .padding(.horizontal, Constants.Spacing.horizontalPadding)
        .background(Constants.Colors.white)
        .sheet(isPresented: $viewModel.didPresentError) {
            errorSheet
        }
        .endEditingOnTap()
    }

    private var header: some View {
        HStack {
            Text("Link your")
                .font(Constants.Fonts.h3)
                .foregroundStyle(Constants.Colors.black)

            Image("venmoLogo")
        }
    }

    private var caption: some View {
        Text("Your Venmo handle will only be visible to people interested in buying your listing.")
            .font(Constants.Fonts.body1)
            .foregroundStyle(Constants.Colors.secondaryGray)
            .padding(.top, Constants.Venmo.captionTopPadding)
    }

    private var continueButton: some View {
        PurpleButton(
            isLoading: viewModel.isLoading,
            isActive: !mainViewModel.venmoHandle.cleaned().isEmpty,
            text: "Continue"
        ) {
            viewModel.submit(main: mainViewModel)
        }
    }

    private var skipButton: some View {
        Button {
            viewModel.skip(main: mainViewModel)
        } label: {
            Text("Skip")
                .font(Constants.Fonts.title1)
                .foregroundStyle(Constants.Colors.resellPurple)
                .padding(.top, Constants.Venmo.skipTopPadding)
        }
        .disabled(viewModel.isLoading)
    }

    private var errorSheet: some View {
        VStack {
            Text(viewModel.errorText)
                .font(Constants.Fonts.h3)
                .multilineTextAlignment(.center)
                .frame(width: Constants.Login.errorTextWidth)
                .padding(.top, Constants.Login.errorTextTopPadding)

            Spacer()

            PurpleButton(text: "OK", horizontalPadding: 60) {
                viewModel.didPresentError = false
            }
        }
        .presentationDetents([.height(Constants.Login.errorSheetHeight)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(25)
    }
}

#Preview {
    VenmoView()
        .environmentObject(MainView.ViewModel())
}
