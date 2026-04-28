//
//  MainTabView.swift
//  FitnessApp
//
//  Updated by Leyla Jafarova on 26/04/2026.

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var workoutVM = WorkoutViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab.workouts", comment: ""),
                        systemImage: "dumbbell.fill"
                    )
                }
                .environmentObject(workoutVM)

        
            NutritionView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab.nutrition", comment: ""),
                        systemImage: "fork.knife"
                    )
                }

            StatsView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab.stats", comment: ""),
                        systemImage: "chart.bar.fill"
                    )
                }
                .environmentObject(workoutVM)

            
            FriendsView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab.friends", comment: ""),
                        systemImage: "person.2.fill"
                    )
                }


            ProfileView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab.profile", comment: ""),
                        systemImage: "person.fill"
                    )
                }
                .environmentObject(workoutVM)
        }
        .id(Locale.current.language.languageCode?.identifier)
        .tint(AppTheme.lime)
        .onAppear { styleTabBar() }
        .environmentObject(workoutVM)
        .task {
            let uid = authVM.currentUser?.id ?? authVM.userSession?.uid ?? ""
            guard !uid.isEmpty else { return }
            await workoutVM.fetchWorkouts(userId: uid)
        }
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.card)
        appearance.shadowColor     = UIColor(AppTheme.border)

        let lime = UIColor(AppTheme.lime)
        let gray = UIColor(AppTheme.muted)

        [appearance.stackedLayoutAppearance,
         appearance.inlineLayoutAppearance,
         appearance.compactInlineLayoutAppearance].forEach { layout in
            layout.selected.iconColor  = lime
            layout.selected.titleTextAttributes = [.foregroundColor: lime]
            layout.normal.iconColor    = gray
            layout.normal.titleTextAttributes   = [.foregroundColor: gray]
        }

        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
