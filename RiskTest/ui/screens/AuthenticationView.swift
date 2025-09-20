//
//  AuthenticationView.swift
//  RiskTest
//
//  Created by selinay ceylan on 19.09.2025.
//

import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        NavigationStack {
            if viewModel.isAuthenticated {
                if viewModel.isNewUser {
                    OnBoardingView()
                        .navigationBarBackButtonHidden(true)
                } else {
                    HomeView(authViewModel: viewModel)
                        .navigationBarBackButtonHidden(true)
                }
            } else {
                SignInView()
            }
        }
        .onAppear {
            viewModel.checkAuthenticationStatus()
        }
    }
}

#Preview {
    AuthenticationView()
}
