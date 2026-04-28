//
//  WorkoutsView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//


import SwiftUI
import FirebaseAuth

struct WorkoutsView: View {
    @EnvironmentObject var authVM:    AuthViewModel
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.dark.ignoresSafeArea()
                Group {
                    if workoutVM.isLoading        { loadingView  }
                    else if workoutVM.workouts.isEmpty { emptyState }
                    else                          { workoutList  }
                }
            }
            .navigationTitle(NSLocalizedString("tab.workouts", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: {
                        ZStack {
                            Circle().fill(AppTheme.lime).frame(width: 34, height: 34)
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddWorkoutView().environmentObject(authVM).environmentObject(workoutVM)
            }
            .refreshable {
                let uid = authVM.currentUser?.id ?? authVM.userSession?.uid ?? ""
                guard !uid.isEmpty else { return }
                await workoutVM.fetchWorkouts(userId: uid)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView().tint(AppTheme.lime)
            Text(NSLocalizedString("workouts.loading", comment: ""))
                .font(.system(size: 14)).foregroundColor(AppTheme.muted)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var workoutList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(workoutVM.workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        DarkWorkoutCard(workout: workout)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task {
                                let uid = authVM.currentUser?.id ?? authVM.userSession?.uid ?? ""
                                guard !uid.isEmpty else { return }
                                await workoutVM.deleteWorkout(workout, userId: uid)
                            }
                        } label: {
                            Label(NSLocalizedString("workouts.delete", comment: ""), systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 30)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(AppTheme.lime.opacity(0.1)).frame(width: 90, height: 90)
                Image(systemName: "figure.run.circle")
                    .font(.system(size: 44)).foregroundColor(AppTheme.lime.opacity(0.6))
            }
            Text(NSLocalizedString("workouts.empty", comment: ""))
                .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Text(NSLocalizedString("workouts.emptySub", comment: ""))
                .font(.system(size: 14)).foregroundColor(AppTheme.muted).multilineTextAlignment(.center)
            Button { showAdd = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus").font(.system(size: 14, weight: .bold))
                    Text(NSLocalizedString("workouts.add", comment: "")).font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 28).padding(.vertical, 14)
                .background(AppTheme.lime).cornerRadius(100)
            }.padding(.top, 8)
        }
        .padding(30).frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: — DarkWorkoutCard

struct DarkWorkoutCard: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                if let url = workout.videoURLs.first,
                   let thumb = youtubeThumbnailURL(from: url) {
                    AsyncImage(url: thumb) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFill()
                        } else {
                            iconFallback
                        }
                    }
                } else {
                    iconFallback
                }
            }
            .frame(width: 54, height: 54).cornerRadius(14).clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                Text(workout.type.localizedName)
                    .font(.system(size: 12)).foregroundColor(AppTheme.muted)
                if !workout.exercises.isEmpty {
                    Text("\(workout.exercises.count) \(NSLocalizedString("workouts.exercises", comment: ""))")
                        .font(.system(size: 11)).foregroundColor(AppTheme.lime)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "clock").font(.system(size: 10)).foregroundColor(AppTheme.muted)
                    Text("\(workout.duration) \(NSLocalizedString("workouts.min", comment: ""))")
                        .font(.system(size: 11)).foregroundColor(AppTheme.muted)
                }
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").font(.system(size: 10)).foregroundColor(.orange)
                    Text("\(workout.calories) \(NSLocalizedString("workouts.kcal", comment: ""))")
                        .font(.system(size: 11)).foregroundColor(.orange)
                }
                if !workout.videoURLs.isEmpty {
                    Image(systemName: "play.circle.fill")
                }
            }
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(AppTheme.muted)
        }
        .padding(14)
        .background(AppTheme.card).cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.border, lineWidth: 1))
    }

    private var iconFallback: some View {
        ZStack {
            AppTheme.gradient(for: workout.type)
            Image(systemName: workout.type.icon).font(.system(size: 22))
                .foregroundColor(AppTheme.color(for: workout.type))
        }
    }
}

struct WorkoutCard: View {
    let workout: Workout
    var body: some View { DarkWorkoutCard(workout: workout) }
}
struct EmptyWorkoutsView: View {
    var body: some View { EmptyView() }
}
