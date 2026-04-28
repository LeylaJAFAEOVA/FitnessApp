//
//  OnboardingView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 06/04/2026.
//

import SwiftUI

struct OnboardingPage {
    let image: String       
    let title: String
    let highlight: String
    let subtitle: String
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "figure.run",
            title: "Wherever You Are",
            highlight: "Health",
            subtitle: "There is no instant way to a healthy life"
        ),
        OnboardingPage(
            image: "figure.strengthtraining.traditional",
            title: "Track Your",
            highlight: "Progress",
            subtitle: "Monitor every workout and stay consistent"
        ),
        OnboardingPage(
            image: "figure.yoga",
            title: "Achieve Your",
            highlight: "Goals",
            subtitle: "Set targets and crush them every day"
        )
    ]

    var body: some View {
        ZStack {
            AppTheme.dark.ignoresSafeArea()

            VStack(spacing: 0) {
                // Image area
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [AppTheme.lime.opacity(0.3), AppTheme.dark],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    // Icon (замени на AsyncImage если есть реальные фото)
                    Image(systemName: pages[currentPage].image)
                        .font(.system(size: 140))
                        .foregroundColor(AppTheme.lime.opacity(0.85))
                        .padding(.top, 80)
                }
                .frame(height: UIScreen.main.bounds.height * 0.55)

                // Content
                VStack(spacing: 16) {
                    // Title with highlight
                    VStack(spacing: 4) {
                        Text(pages[currentPage].title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text(pages[currentPage].highlight + " Is Number One")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.lime, AppTheme.lime.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .multilineTextAlignment(.center)

                    Text(pages[currentPage].subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // Dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? AppTheme.lime : AppTheme.muted.opacity(0.4))
                                .frame(width: i == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.top, 8)

                    // Button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            hasSeenOnboarding = true
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.lime)
                            .cornerRadius(100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Skip
                    if currentPage < pages.count - 1 {
                        Button { hasSeenOnboarding = true } label: {
                            Text("Skip")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.muted)
                        }
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 50)
                .frame(maxWidth: .infinity)
                .background(AppTheme.dark)
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}
