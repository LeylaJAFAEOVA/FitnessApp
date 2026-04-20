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

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView()
        } else if authVM.userSession == nil {
            LoginView()
        } else {
            MainTabView()
        }
    }
}
