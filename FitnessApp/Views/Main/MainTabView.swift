//
//  MainTabView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//



import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var workoutVM = WorkoutViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(NSLocalizedString("tab.home", comment: ""), systemImage: "house.fill")
                }

            ExploreView()
                .tabItem {
                    Label(NSLocalizedString("tab.explore", comment: ""), systemImage: "safari.fill")
                }

            WorkoutsView()
                .tabItem {
                    Label(NSLocalizedString("tab.workouts", comment: ""), systemImage: "dumbbell.fill")
                }

            StatsView()
                .tabItem {
                    Label(NSLocalizedString("tab.stats", comment: ""), systemImage: "chart.bar.fill")
                }

            ProfileView()
                .tabItem {
                    Label(NSLocalizedString("tab.profile", comment: ""), systemImage: "person.fill")
                }
        }
        .id(Locale.current.language.languageCode?.identifier) // ← это заставит TabBar перерисоваться
        // Lime green accent
        .tint(AppTheme.lime)
        .onAppear { styleTabBar() }

        .environmentObject(workoutVM)
        .task {
            let uid = authVM.currentUser?.id ?? authVM.userSession?.uid ?? ""
            guard !uid.isEmpty else { return }
            await workoutVM.fetchWorkouts(userId: uid)
        }
    }

    // MARK: — Dark tab bar styling

    private func styleTabBar() {
        let a = UITabBarAppearance()
        a.configureWithOpaqueBackground()
        a.backgroundColor    = UIColor(AppTheme.card)
        a.shadowColor        = UIColor(AppTheme.border)

        let lime = UIColor(AppTheme.lime)
        let gray = UIColor(AppTheme.muted)

        [a.stackedLayoutAppearance,
         a.inlineLayoutAppearance,
         a.compactInlineLayoutAppearance].forEach { layout in
            layout.selected.iconColor = lime
            layout.selected.titleTextAttributes = [.foregroundColor: lime]
            layout.normal.iconColor = gray
            layout.normal.titleTextAttributes  = [.foregroundColor: gray]
        }

        UITabBar.appearance().standardAppearance   = a
        UITabBar.appearance().scrollEdgeAppearance = a
    }
}
