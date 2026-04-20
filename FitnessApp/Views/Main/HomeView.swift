//
//  HomeView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 05/04/2026.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM:    AuthViewModel
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @State private var showAdd = false

    // Динамическое приветствие по времени
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:  return NSLocalizedString("home.greeting.morning",   comment: "")
        case 12..<17: return NSLocalizedString("home.greeting.afternoon", comment: "")
        case 17..<22: return NSLocalizedString("home.greeting.evening",   comment: "")
        default:      return NSLocalizedString("home.greeting.night",     comment: "")
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppTheme.dark.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        topBar
                        popularSection
                        todaySection
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAdd) {
                AddWorkoutView()
                    .environmentObject(authVM)
                    .environmentObject(workoutVM)
            }
        }
    }

    // MARK: — Top bar

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(greetingText)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.muted)
                Text("\(authVM.currentUser?.name ?? "User")!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
            HStack(spacing: 12) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(AppTheme.lime)
                }
                ZStack {
                    Circle().fill(AppTheme.lime).frame(width: 42, height: 42)
                    Text(String(authVM.currentUser?.name.prefix(2).uppercased() ?? "FP"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: — Popular Workouts

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(NSLocalizedString("home.popular", comment: ""))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                NavigationLink(destination: WorkoutsView()) {
                    Text(NSLocalizedString("home.see_all", comment: ""))
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.lime)
                }
            }
            .padding(.horizontal, 20)

            if workoutVM.isLoading {
                loadingRow
            } else if workoutVM.workouts.isEmpty {
                emptyHint
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(workoutVM.workouts.prefix(10)) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutVideoCard(workout: workout)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: — Today Plan

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("home.today_plan", comment: ""))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            if workoutVM.workoutsThisWeek.isEmpty {
                Text(NSLocalizedString("home.no_workouts", comment: ""))
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.muted)
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(workoutVM.workoutsThisWeek.prefix(3)) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            TodayPlanCard(workout: workout)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: — Helpers

    private var loadingRow: some View {
        HStack { Spacer(); ProgressView().tint(AppTheme.lime); Spacer() }
            .frame(height: 140)
    }

    private var emptyHint: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.lime.opacity(0.5))
            Text(NSLocalizedString("home.add_first", comment: ""))
                .font(.system(size: 14))
                .foregroundColor(AppTheme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(AppTheme.card)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border, lineWidth: 1))
        .padding(.horizontal, 20)
    }
}

// MARK: — WorkoutVideoCard

struct WorkoutVideoCard: View {
    let workout: Workout

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            thumbnailView
                .frame(width: 185, height: 125)
                .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.85), Color.clear],
                startPoint: .bottom, endPoint: .center
            )

            // Duration badge — top left
            VStack {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 8))
                        Text("\(workout.duration) \(NSLocalizedString("workouts.min", comment: ""))")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.lime)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.65))
                    .cornerRadius(20)
                    Spacer()
                }
                Spacer()
            }
            .padding(9)

            // Title + play button
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text(workout.type.localizedName)
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.muted)
                }
                Spacer()
                ZStack {
                    Circle().fill(AppTheme.lime).frame(width: 30, height: 30)
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                        .offset(x: 1)
                }
            }
            .padding(10)
        }
        .frame(width: 185, height: 125)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.border, lineWidth: 1))
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let url = workout.videoURLs.first,
           let thumb = youtubeThumbnailURL(from: url) {
            AsyncImage(url: thumb) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    gradientFallback
                }
            }
        } else {
            gradientFallback
        }
    }

    private var gradientFallback: some View {
        ZStack {
            AppTheme.gradient(for: workout.type)
            Image(systemName: workout.type.icon)
                .font(.system(size: 30))
                .foregroundColor(AppTheme.color(for: workout.type).opacity(0.35))
        }
    }
}

// MARK: — TodayPlanCard

struct TodayPlanCard: View {
    let workout: Workout

    private var progress: Double { min(Double(workout.calories) / 600.0, 1.0) }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                if let url = workout.videoURLs.first,
                   let thumb = youtubeThumbnailURL(from: url) {
                    AsyncImage(url: thumb) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFill()
                        } else {
                            gradientThumb
                        }
                    }
                } else {
                    gradientThumb
                }
            }
            .frame(width: 52, height: 52)
            .cornerRadius(12)
            .clipped()

            VStack(alignment: .leading, spacing: 5) {
                Text(workout.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(
                    "\(workout.duration) \(NSLocalizedString("workouts.min", comment: ""))  ·  " +
                    "\(workout.calories) \(NSLocalizedString("workouts.kcal", comment: ""))"
                )
                .font(.system(size: 11))
                .foregroundColor(AppTheme.muted)

                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppTheme.border)
                        Capsule().fill(AppTheme.lime)
                            .frame(width: g.size.width * progress)
                    }
                }
                .frame(height: 4)
            }

            Spacer(minLength: 0)

            Text("\(Int(progress * 100))%")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.lime)
        }
        .padding(14)
        .background(AppTheme.card)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
    }

    private var gradientThumb: some View {
        ZStack {
            AppTheme.gradient(for: workout.type)
            Image(systemName: workout.type.icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.color(for: workout.type))
        }
    }
}
