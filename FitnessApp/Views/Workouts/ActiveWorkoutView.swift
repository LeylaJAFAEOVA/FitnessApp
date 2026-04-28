//
//  ActiveWorkoutView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 28/04/2026.
//

import SwiftUI

// MARK: — ActiveWorkoutView

struct ActiveWorkoutView: View {
    let workout: Workout
    @EnvironmentObject var authVM:    AuthViewModel
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @Environment(\.dismiss) var dismiss

    // Timer
    @State private var secondsElapsed: Int = 0
    @State private var timerRunning:   Bool = true
    @State private var timer: Timer? = nil

    // Exercise state
    @State private var currentIndex: Int = 0
    @State private var currentSet:   Int = 1
    @State private var completedSets: [String: Int] = [:]  // exerciseId -> setsCompleted

    // UI state
    @State private var showFinishAlert  = false
    @State private var showCompletedSheet = false
    @State private var restCountdown:   Int? = nil
    @State private var restTimer: Timer? = nil

    private var exercises: [Exercise] { workout.exercises }
    private var currentExercise: Exercise? {
        guard currentIndex < exercises.count else { return nil }
        return exercises[currentIndex]
    }
    private var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        let totalSets = exercises.reduce(0) { $0 + $1.sets }
        let doneSets  = completedSets.values.reduce(0, +)
        return Double(doneSets) / Double(totalSets)
    }

    var body: some View {
        ZStack {
            AppTheme.dark.ignoresSafeArea()

            if showCompletedSheet {
                completedView
            } else {
                VStack(spacing: 0) {
                    topBar
                    progressBar
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            timerCard
                            if let ex = currentExercise {
                                currentExerciseCard(ex)
                            }
                            if exercises.count > 1 {
                                exerciseQueue
                            }
                            Spacer(minLength: 30)
                        }
                        .padding(.bottom, 100)
                    }
                    bottomControls
                }
            }

            // Rest overlay
            if let rest = restCountdown {
                restOverlay(rest)
            }
        }
        .navigationBarHidden(true)
        .onAppear { startTimer() }
        .onDisappear { stopTimer(); stopRestTimer() }
        .alert(NSLocalizedString("active.finish_alert_title", comment: ""), isPresented: $showFinishAlert) {
            Button(NSLocalizedString("active.finish_confirm", comment: ""), role: .destructive) {
                finishWorkout()
            }
            Button(NSLocalizedString("active.finish_cancel", comment: ""), role: .cancel) {}
        } message: {
            Text(NSLocalizedString("active.finish_alert_message", comment: ""))
        }
    }

    // MARK: — Top Bar

    private var topBar: some View {
        HStack {
            Button { showFinishAlert = true } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.muted)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.border, lineWidth: 1))
            }

            Spacer()

            VStack(spacing: 2) {
                Text(workout.title)
                    .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                Text(workout.type.localizedName)
                    .font(.system(size: 11)).foregroundColor(AppTheme.muted)
            }

            Spacer()

            // Pause / Resume
            Button {
                timerRunning ? pauseTimer() : startTimer()
            } label: {
                Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.lime)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.lime.opacity(0.15))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.lime.opacity(0.3), lineWidth: 1))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: — Progress Bar

    private var progressBar: some View {
        VStack(spacing: 4) {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppTheme.card2)
                    Capsule().fill(AppTheme.lime)
                        .frame(width: g.size.width * progress)
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)

            HStack {
                Text(String(format: NSLocalizedString("active.exercise_of", comment: ""),
                            min(currentIndex + 1, exercises.count), exercises.count))
                    .font(.system(size: 11)).foregroundColor(AppTheme.muted)
                Spacer()
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.system(size: 11, weight: .semibold)).foregroundColor(AppTheme.lime)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
    }

    // MARK: — Timer Card

    private var timerCard: some View {
        HStack(spacing: 0) {
            // Elapsed time
            VStack(spacing: 4) {
                Image(systemName: "clock").foregroundColor(.blue).font(.system(size: 16))
                Text(formattedTime(secondsElapsed))
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text(NSLocalizedString("active.elapsed", comment: ""))
                    .font(.system(size: 10)).foregroundColor(AppTheme.muted)
            }
            .frame(maxWidth: .infinity)

            Rectangle().fill(AppTheme.border).frame(width: 1, height: 50)

            // Calories burned (estimated)
            VStack(spacing: 4) {
                Image(systemName: "flame.fill").foregroundColor(.orange).font(.system(size: 16))
                Text("\(estimatedCalories)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text(NSLocalizedString("detail.kcal", comment: ""))
                    .font(.system(size: 10)).foregroundColor(AppTheme.muted)
            }
            .frame(maxWidth: .infinity)

            Rectangle().fill(AppTheme.border).frame(width: 1, height: 50)

            // Sets done
            VStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill").foregroundColor(AppTheme.lime).font(.system(size: 16))
                Text("\(completedSets.values.reduce(0, +))")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text(NSLocalizedString("active.sets_done", comment: ""))
                    .font(.system(size: 10)).foregroundColor(AppTheme.muted)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .background(AppTheme.card)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border, lineWidth: 1))
        .padding(.horizontal, 20)
    }

    // MARK: — Current Exercise Card

    private func currentExerciseCard(_ ex: Exercise) -> some View {
        let done = completedSets[ex.id] ?? 0
        let remaining = ex.sets - done

        return VStack(spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.lime.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: workout.type.icon)
                        .font(.system(size: 22)).foregroundColor(AppTheme.lime)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(NSLocalizedString("active.current_exercise", comment: ""))
                        .font(.system(size: 11)).foregroundColor(AppTheme.muted)
                    Text(ex.name)
                        .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                }
                Spacer()
                // Set counter badge
                Text("\(done)/\(ex.sets)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(AppTheme.lime)
                    .cornerRadius(20)
            }

            // Reps & weight
            HStack(spacing: 12) {
                infoChip(icon: "repeat", value: "\(ex.reps)", label: NSLocalizedString("detail.reps", comment: ""))
                infoChip(icon: "list.number", value: "\(remaining)", label: NSLocalizedString("active.sets_left", comment: ""))
                if let w = ex.weight {
                    infoChip(icon: "scalemass", value: "\(Int(w))", label: NSLocalizedString("profile.kg", comment: ""))
                }
            }

            // Sets dots
            HStack(spacing: 8) {
                ForEach(0..<ex.sets, id: \.self) { i in
                    Circle()
                        .fill(i < done ? AppTheme.lime : AppTheme.border)
                        .frame(width: 10, height: 10)
                        .animation(.spring(response: 0.3), value: done)
                }
                Spacer()
            }

            // Complete set button
            Button {
                completeSet(ex)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark").font(.system(size: 14, weight: .bold))
                    Text(remaining > 1
                         ? NSLocalizedString("active.complete_set", comment: "")
                         : NSLocalizedString("active.complete_last_set", comment: ""))
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(remaining > 0 ? AppTheme.lime : AppTheme.muted)
                .cornerRadius(100)
            }
            .disabled(remaining == 0)
        }
        .padding(18)
        .background(AppTheme.card)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.lime.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 20)
    }

    private func infoChip(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(AppTheme.muted)
            Text(value).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(AppTheme.muted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(AppTheme.card2).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 1))
    }

    // MARK: — Exercise Queue

    private var exerciseQueue: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("active.up_next", comment: ""))
                .font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.muted)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(Array(exercises.enumerated()), id: \.element.id) { idx, ex in
                    let done = completedSets[ex.id] ?? 0
                    let isCompleted = done >= ex.sets
                    let isCurrent  = idx == currentIndex

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isCompleted ? AppTheme.lime :
                                      isCurrent   ? AppTheme.lime.opacity(0.2) : AppTheme.card2)
                                .frame(width: 28, height: 28)
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold)).foregroundColor(.black)
                            } else {
                                Text("\(idx + 1)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(isCurrent ? AppTheme.lime : AppTheme.muted)
                            }
                        }

                        Text(ex.name)
                            .font(.system(size: 13, weight: isCurrent ? .semibold : .regular))
                            .foregroundColor(isCompleted ? AppTheme.muted : .white)
                            .strikethrough(isCompleted)

                        Spacer()

                        Text("\(ex.sets)×\(ex.reps)")
                            .font(.system(size: 11)).foregroundColor(AppTheme.muted)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(isCurrent ? AppTheme.lime.opacity(0.05) : AppTheme.card)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCurrent ? AppTheme.lime.opacity(0.3) : AppTheme.border, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: — Bottom Controls

    private var bottomControls: some View {
        HStack(spacing: 12) {
            // Skip exercise
            Button {
                skipToNext()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "forward.fill").font(.system(size: 13))
                    Text(NSLocalizedString("active.skip", comment: ""))
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(AppTheme.muted)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(AppTheme.card)
                .cornerRadius(100)
                .overlay(RoundedRectangle(cornerRadius: 100).stroke(AppTheme.border, lineWidth: 1))
            }

            // Finish workout
            Button { showFinishAlert = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "flag.checkered").font(.system(size: 13))
                    Text(NSLocalizedString("active.finish", comment: ""))
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(AppTheme.lime)
                .cornerRadius(100)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            AppTheme.dark
                .overlay(Rectangle().fill(AppTheme.border).frame(height: 1), alignment: .top)
        )
    }

    // MARK: — Rest Overlay

    private func restOverlay(_ seconds: Int) -> some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 20) {
                Text(NSLocalizedString("active.rest", comment: ""))
                    .font(.system(size: 24, weight: .bold)).foregroundColor(.white)

                ZStack {
                    Circle().stroke(AppTheme.card2, lineWidth: 8).frame(width: 130, height: 130)
                    Circle().trim(from: 0, to: Double(seconds) / 30.0)
                        .stroke(AppTheme.lime, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: seconds)
                    Text("\(seconds)")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.lime)
                }

                Text(NSLocalizedString("active.rest_subtitle", comment: ""))
                    .font(.system(size: 14)).foregroundColor(AppTheme.muted)

                Button {
                    stopRestTimer()
                } label: {
                    Text(NSLocalizedString("active.skip_rest", comment: ""))
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.black)
                        .padding(.horizontal, 32).padding(.vertical, 12)
                        .background(AppTheme.lime).cornerRadius(100)
                }
            }
        }
    }

    // MARK: — Completed View

    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Trophy
            ZStack {
                Circle().fill(AppTheme.lime.opacity(0.15)).frame(width: 100, height: 100)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 44)).foregroundColor(AppTheme.lime)
            }

            Text(NSLocalizedString("active.completed_title", comment: ""))
                .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
            Text(workout.title)
                .font(.system(size: 16)).foregroundColor(AppTheme.muted)

            // Stats
            HStack(spacing: 12) {
                completedStat(icon: "clock", value: formattedTime(secondsElapsed),
                              label: NSLocalizedString("active.elapsed", comment: ""), color: .blue)
                completedStat(icon: "flame.fill", value: "\(estimatedCalories)",
                              label: NSLocalizedString("detail.kcal", comment: ""), color: .orange)
                completedStat(icon: "checkmark.circle.fill",
                              value: "\(completedSets.values.reduce(0, +))",
                              label: NSLocalizedString("active.sets_done", comment: ""), color: AppTheme.lime)
            }
            .padding(.horizontal, 20)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text(NSLocalizedString("active.done", comment: ""))
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(AppTheme.lime).cornerRadius(100)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private func completedStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 20))
            Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(AppTheme.muted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(AppTheme.card).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
    }

    // MARK: — Logic

    private func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            secondsElapsed += 1
        }
    }

    private func pauseTimer() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func completeSet(_ ex: Exercise) {
        let done = (completedSets[ex.id] ?? 0) + 1
        completedSets[ex.id] = done

        if done >= ex.sets {
            // All sets done — move to next exercise after rest
            startRestTimer {
                skipToNext()
            }
        } else {
            // More sets remain — short rest
            startRestTimer(onComplete: nil)
        }
    }

    private func skipToNext() {
        stopRestTimer()
        if currentIndex + 1 < exercises.count {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
            }
        } else {
            // All exercises done
            finishWorkout()
        }
    }

    private func startRestTimer(onComplete: (() -> Void)? = nil) {
        restCountdown = 30
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if let current = restCountdown {
                if current <= 1 {
                    stopRestTimer()
                    onComplete?()
                } else {
                    restCountdown = current - 1
                }
            }
        }
    }

    private func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        restCountdown = nil
    }

    private func finishWorkout() {
        stopTimer()
        stopRestTimer()
        withAnimation(.easeInOut(duration: 0.5)) {
            showCompletedSheet = true
        }
    }

    private var estimatedCalories: Int {
        let ratio = Double(secondsElapsed) / Double(workout.duration * 60)
        return Int(Double(workout.calories) * min(ratio, 1.0))
    }

    private func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
