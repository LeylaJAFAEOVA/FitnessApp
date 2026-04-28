//
//  ContentView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 07/04/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    @State private var splashDone = false
    var body: some View {
        if !splashDone || authVM.isCheckingAuth {
            SplashView()
                .task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    splashDone = true
                }
        } else if !hasSeenOnboarding {
            OnboardingView()
        } else if authVM.userSession == nil {
            LoginView()
        } else {
            MainTabView()
        }
    }
}
