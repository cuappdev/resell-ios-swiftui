//
//  LoginView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import SwiftUI

struct LoginView: View {

    // MARK: - Properties

    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @StateObject private var viewModel = ViewModel()

    // MARK: - UI

    var body: some View {
        VStack {
            logo

            Spacer()

            loginButton
        }
        .background(LoginGradient())
        .sheet(isPresented: $viewModel.didPresentError) {
            errorSheet
        }
    }

    private var logo: some View {
        VStack {
            Image("resell")
                .padding(.top, Constants.Login.logoTopPadding)

            Text("resell")
                .font(Constants.Fonts.resellLogo)
                .foregroundStyle(Constants.Colors.resellGradient)
                .multilineTextAlignment(.center)
        }
    }

    private var loginButton: some View {
        PurpleButton(
            isLoading: viewModel.isLoading,
            text: "Login with NetID",
            horizontalPadding: Constants.Login.buttonHorizontalPadding
        ) {
            viewModel.signIn(main: mainViewModel)
        }
    }

    private var errorSheet: some View {
        VStack {
            Text(viewModel.errorText)
                .font(Constants.Fonts.h3)
                .multilineTextAlignment(.center)
                .frame(width: Constants.Login.errorTextWidth)
                .padding(.top, Constants.Login.errorTextTopPadding)

            Spacer()

            PurpleButton(text: "Try Again", horizontalPadding: 60) {
                viewModel.didPresentError = false
                viewModel.signIn(main: mainViewModel)
            }
        }
        .presentationDetents([.height(Constants.Login.errorSheetHeight)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(25)
    }
}

#Preview {
    LoginView()
        .environmentObject(MainView.ViewModel())
}
