//
//  ExploreView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 05/04/2026.
//


import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel

    @State private var search      = ""
    @State private var filterType: Workout.WorkoutType? = nil

    private var results: [Workout] {
        var list = workoutVM.workouts
        if let t = filterType { list = list.filter { $0.type == t } }
        if !search.isEmpty   { list = list.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            $0.type.localizedName.localizedCaseInsensitiveContains(search)
        }}
        return list
    }

    private var hero: Workout? {
        workoutVM.workouts.first(where: { !$0.videoURLs.isEmpty }) ?? workoutVM.workouts.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.dark.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        searchBar
                        if let h = hero { heroCard(h) }
                        filterChips
                        gridSection
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(LocalizedStringKey("explore.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.dark, for: .navigationBar)
        }
    }

    // MARK: — Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.muted)
                .font(.system(size: 15))
            TextField("", text: $search)
                .placeholder(when: search.isEmpty) {
                    Text(LocalizedStringKey("explore.search")).foregroundColor(AppTheme.muted)
                }
                .foregroundColor(.white)
                .font(.system(size: 14))
            if !search.isEmpty {
                Button { search = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.muted).font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.card)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 1))
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    // MARK: — Hero card

    private func heroCard(_ workout: Workout) -> some View {
        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
            ZStack(alignment: .bottomLeading) {
                // Background
                Group {
                    if let url = workout.videoURLs.first, let thumb = youtubeThumbnailURL(from: url) {
                        AsyncImage(url: thumb) { phase in
                            if case .success(let img) = phase { img.resizable().scaledToFill() }
                            else { gradientBG(workout) }
                        }
                    } else { gradientBG(workout) }
                }
                .frame(maxWidth: .infinity).frame(height: 190).clipped()

                // Gradient
                LinearGradient(
                    colors: [Color.black.opacity(0.80), Color.clear],
                    startPoint: .bottomLeading, endPoint: .topTrailing
                )

                // Text
                VStack(alignment: .leading, spacing: 5) {
                    Text(workout.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(String(localized: "home.see_all") + " →")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.lime)
                }
                .padding(18)

                // NEW badge
                VStack {
                    HStack {
                        Spacer()
                        Text("NEW")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.black)
                            .padding(.horizontal, 9).padding(.vertical, 4)
                            .background(AppTheme.lime).cornerRadius(20)
                    }
                    Spacer()
                }
                .padding(14)

                // Play ring
                HStack {
                    Spacer()
                    ZStack {
                        Circle().stroke(AppTheme.lime.opacity(0.3), lineWidth: 2).frame(width: 56, height: 56)
                        Circle().fill(AppTheme.lime).frame(width: 38, height: 38)
                        Image(systemName: "play.fill")
                            .font(.system(size: 13)).foregroundColor(.black).offset(x: 1)
                    }
                    .padding(.trailing, 20).padding(.bottom, 20)
                }
            }
            .frame(height: 190).cornerRadius(22)
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(AppTheme.border, lineWidth: 1))
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
    }

    // MARK: — Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(label: NSLocalizedString("explore.all", comment: ""), isActive: filterType == nil) {
                    filterType = nil
                }
                ForEach(Workout.WorkoutType.allCases, id: \.self) { type in
                    chip(
                        label: type.localizedName,
                        icon: type.icon,
                        accent: AppTheme.color(for: type),
                        isActive: filterType == type
                    ) { filterType = filterType == type ? nil : type }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func chip(
        label: String,
        icon: String? = nil,
        accent: Color = AppTheme.lime,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon { Image(systemName: icon).font(.system(size: 11)) }
                Text(label).font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isActive ? .black : AppTheme.muted)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(isActive ? AppTheme.lime : AppTheme.card)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isActive ? Color.clear : AppTheme.border, lineWidth: 1)
            )
        }
    }

    // MARK: — Grid

    @ViewBuilder
    private var gridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(results.isEmpty ? "explore.no_results" : "explore.best_for_you"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            if workoutVM.isLoading {
                HStack { Spacer(); ProgressView().tint(AppTheme.lime); Spacer() }
            } else if results.isEmpty {
                Text(LocalizedStringKey("explore.no_results"))
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.muted)
                    .padding(.horizontal, 20)
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(results) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            ExploreGridCard(workout: workout)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: — Helpers

    private func gradientBG(_ workout: Workout) -> some View {
        ZStack {
            AppTheme.gradient(for: workout.type)
            Image(systemName: workout.type.icon)
                .font(.system(size: 50))
                .foregroundColor(AppTheme.color(for: workout.type).opacity(0.2))
        }
    }
}

// MARK: — ExploreGridCard

struct ExploreGridCard: View {
    let workout: Workout

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            Group {
                if let url = workout.videoURLs.first, let thumb = youtubeThumbnailURL(from: url) {
                    AsyncImage(url: thumb) { phase in
                        if case .success(let img) = phase { img.resizable().scaledToFill() }
                        else { bg }
                    }
                } else { bg }
            }
            .frame(maxWidth: .infinity).frame(height: 115).clipped()

            // Overlay
            LinearGradient(
                colors: [Color.black.opacity(0.75), Color.clear],
                startPoint: .bottom, endPoint: .center
            )

            // Mini play — center
            ZStack {
                Circle().fill(AppTheme.lime.opacity(0.9)).frame(width: 28, height: 28)
                Image(systemName: "play.fill").font(.system(size: 10)).foregroundColor(.black).offset(x: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 30)

            // Label
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white).lineLimit(1)
                Text("\(workout.duration) \(NSLocalizedString("workouts.min", comment: "")) · \(workout.type.localizedName)")
                    .font(.system(size: 9)).foregroundColor(AppTheme.muted)
            }
            .padding(9)
        }
        .frame(height: 115)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
    }

    private var bg: some View {
        ZStack {
            AppTheme.gradient(for: workout.type)
            Image(systemName: workout.type.icon)
                .font(.system(size: 26))
                .foregroundColor(AppTheme.color(for: workout.type).opacity(0.35))
        }
    }
}
