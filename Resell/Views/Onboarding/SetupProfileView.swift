//
//  SetupProfileView.swift
//  Resell
//
//  Created by jiwon jeong on 10/8/26.
//

import PhotosUI
import SwiftUI

struct SetupProfileView: View {

    // MARK: - Properties

    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @StateObject private var viewModel = ViewModel()

    // MARK: - UI

    var body: some View {
        VStack {
            header

            profileImageButton
                .padding(.vertical, Constants.SetupProfile.imageVerticalPadding)

            LabeledTextField(label: "Username", text: $mainViewModel.username)
                .padding(.bottom, Constants.SetupProfile.usernameBottomPadding)

            LabeledTextField(
                label: "Bio",
                maxCharacters: Constants.SetupProfile.bioMaxCharacters,
                frameHeight: Constants.SetupProfile.bioHeight,
                isMultiLine: true,
                text: $mainViewModel.bio
            )
            .padding(.bottom, Constants.SetupProfile.bioBottomPadding)

            eulaRow

            Spacer()

            nextButton
        }
        .padding(.horizontal, Constants.Spacing.horizontalPadding)
        .background(Constants.Colors.white)
        .photosPicker(
            isPresented: $viewModel.didShowPhotosPicker,
            selection: $viewModel.selectedItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: viewModel.selectedItem) { loadSelectedImage() }
        .sheet(isPresented: $viewModel.didShowWebView) {
            WebView(url: URL(string: Constants.SetupProfile.eulaURL)!)
                .ignoresSafeArea()
        }
        .endEditingOnTap()
    }

    private var header: some View {
        Text("Setup your profile")
            .font(Constants.Fonts.h3)
            .foregroundStyle(Constants.Colors.black)
    }

    private var profileImageButton: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: mainViewModel.profileImage ?? .profilePlaceholder)
                .resizable()
                .frame(width: Constants.SetupProfile.imageSize, height: Constants.SetupProfile.imageSize)
                .background(Constants.Colors.stroke)
                .clipShape(.circle)

            Button {
                viewModel.didShowPhotosPicker = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Constants.Colors.resellPurple)
                    .background(Constants.Colors.white.clipShape(.circle))
                    .shadow(radius: 2)
            }
        }
    }

    private var eulaRow: some View {
        HStack(spacing: 0) {
            Button {
                viewModel.didAgreeWithEULA.toggle()
            } label: {
                checkbox
            }

            Text("I agree to Resell's")
                .font(Constants.Fonts.title4)
                .foregroundStyle(Constants.Colors.black)
                .padding(.leading, 16)

            Button {
                viewModel.didShowWebView = true
            } label: {
                Text(UIScreen.width < Constants.SetupProfile.compactScreenWidth ? " EULA" : " End User License Agreement")
                    .font(Constants.Fonts.title4)
                    .foregroundStyle(Constants.Colors.resellPurple)
                    .underline()
            }
        }
    }

    private var checkbox: some View {
        ZStack {
            Circle()
                .fill(Constants.Colors.wash)
                .frame(width: Constants.SetupProfile.checkboxSize, height: Constants.SetupProfile.checkboxSize)
                .overlay {
                    Circle()
                        .stroke(Constants.Colors.resellPurple, lineWidth: Constants.SetupProfile.checkboxBorderWidth)
                }

            if viewModel.didAgreeWithEULA {
                Circle()
                    .fill(Constants.Colors.resellPurple)
                    .frame(width: Constants.SetupProfile.checkboxInnerSize, height: Constants.SetupProfile.checkboxInnerSize)
            }
        }
    }

    private var nextButton: some View {
        PurpleButton(
            isActive: viewModel.isInputValid(
                username: mainViewModel.username,
                bio: mainViewModel.bio,
                hasImage: mainViewModel.profileImage != nil
            ),
            text: "Next",
            horizontalPadding: Constants.SetupProfile.buttonHorizontalPadding
        ) {
            mainViewModel.sessionState = .linkingVenmo
        }
    }

    // MARK: - Actions

    private func loadSelectedImage() {
        Task {
            if let image = await viewModel.loadImage(from: viewModel.selectedItem) {
                mainViewModel.profileImage = image
            }
        }
    }
}

#Preview {
    SetupProfileView()
        .environmentObject(MainView.ViewModel())
}
