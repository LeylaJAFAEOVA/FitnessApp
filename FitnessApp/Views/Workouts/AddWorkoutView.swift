//
//  AddWorkoutView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

import SwiftUI
import FirebaseAuth

struct AddWorkoutView: View {
    @EnvironmentObject var authVM:    AuthViewModel
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title    = ""
    @State private var type     = Workout.WorkoutType.strength
    @State private var duration = 30
    @State private var calories = 200
    @State private var videoURLs: [String] = [""]
    @State private var selected: [ExerciseTemplate] = []
    @State private var isSaving = false

    var filteredTemplates: [ExerciseTemplate] {
        ExerciseTemplate.all.filter { $0.type == type }
    }

    // MARK: — Duration formatter

    private func formatDuration(_ minutes: Int) -> String {
        guard minutes >= 60 else {
            return "\(minutes) \(NSLocalizedString("workouts.min", comment: ""))"
        }
        let h = minutes / 60
        let m = minutes % 60
        return m == 0 ? "\(h)ч" : "\(h)ч \(m)мин"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.dark.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Basic info
                        formSection(NSLocalizedString("add.section.basic", comment: "")) {
                            locTextField(
                                placeholder: NSLocalizedString("add.name.placeholder", comment: ""),
                                text: $title
                            )
                            Divider().background(AppTheme.border)
                            typePicker
                        }

                        formSection(NSLocalizedString("add.section.params", comment: "")) {
                            customStepper(
                                label: NSLocalizedString("add.duration", comment: ""),
                                value: $duration,
                                range: 5...300, step: 5,
                                unit: NSLocalizedString("workouts.min", comment: ""),
                                formatter: formatDuration
                            )
                            Divider().background(AppTheme.border)
                            customStepper(
                                label: NSLocalizedString("add.calories", comment: ""),
                                value: $calories,
                                range: 50...2000, step: 50,
                                unit: NSLocalizedString("workouts.kcal", comment: "")
                            )
                        }

                        formSection(NSLocalizedString("add.section.video", comment: "")) {
                            ForEach(Array(videoURLs.enumerated()), id: \.offset) { idx, _ in
                                if idx > 0 { Divider().background(AppTheme.border) }
                                HStack(spacing: 8) {
                                    TextField("", text: $videoURLs[idx])
                                        .placeholder(when: videoURLs[idx].isEmpty) {
                                            Text("https://youtube.com/watch?v=...")
                                                .foregroundColor(AppTheme.muted)
                                        }
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                        .keyboardType(.URL)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                        .padding(.horizontal, 16).padding(.vertical, 14)
                                    if videoURLs.count > 1 {
                                        Button { videoURLs.remove(at: idx) } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red).font(.system(size: 20))
                                        }.padding(.trailing, 12)
                                    }
                                }
                            }
                            Button { videoURLs.append("") } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text(NSLocalizedString("add.section.video", comment: ""))
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(AppTheme.lime)
                                .padding(.horizontal, 16).padding(.vertical, 12)
                            }
                        }

                        formSection(
                            "\(NSLocalizedString("add.section.exercises", comment: "")) (\(selected.count))"
                        ) {
                            if filteredTemplates.isEmpty {
                                Text(NSLocalizedString("add.no_templates", comment: ""))
                                    .font(.system(size: 14)).foregroundColor(AppTheme.muted).padding(14)
                            } else {
                                ForEach(Array(filteredTemplates.enumerated()), id: \.element.id) { idx, tmpl in
                                    if idx > 0 { Divider().background(AppTheme.border) }
                                    exerciseRow(tmpl)
                                }
                            }
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 40)
                }

                if isSaving {
                    Color.black.opacity(0.55).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView().tint(AppTheme.lime)
                        Text(LocalizedStringKey("add.saving"))
                            .font(.system(size: 14)).foregroundColor(.white)
                    }
                    .padding(24).background(AppTheme.card).cornerRadius(16)
                }
            }
            .navigationTitle(NSLocalizedString("add.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("add.cancel", comment: "")) { dismiss() }
                        .foregroundColor(AppTheme.muted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("add.save", comment: "")) { save() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isSaving ? AppTheme.muted : AppTheme.lime)
                        .disabled(isSaving)
                }
            }
        }
        .onChange(of: type) {
            selected = []
        }
    }

    // MARK: — Type Picker

    private var typePicker: some View {
        HStack {
            Text(NSLocalizedString("add.type", comment: ""))
                .font(.system(size: 15)).foregroundColor(.white)
            Spacer()
            Menu {
                ForEach(Workout.WorkoutType.allCases, id: \.self) { t in
                    Button { type = t; selected = [] } label: {
                        Label(t.localizedName, systemImage: t.icon)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: type.icon).font(.system(size: 13))
                    Text(type.localizedName).font(.system(size: 14))
                    Image(systemName: "chevron.down").font(.system(size: 11))
                }
                .foregroundColor(AppTheme.lime)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    // MARK: — Exercise Row

    private func exerciseRow(_ tmpl: ExerciseTemplate) -> some View {
        let on = selected.contains(where: { $0.id == tmpl.id })
        return HStack(spacing: 12) {
            ZStack {
                Circle().fill(on ? AppTheme.lime : AppTheme.card2).frame(width: 28, height: 28)
                if on {
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(.black)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(tmpl.name).font(.system(size: 14)).foregroundColor(.white)
                Text(
                    "\(tmpl.defaultSets) \(NSLocalizedString("add.sets", comment: "")) × " +
                    "\(tmpl.defaultReps) \(NSLocalizedString("add.reps", comment: ""))"
                )
                .font(.system(size: 11)).foregroundColor(AppTheme.muted)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            if on { selected.removeAll { $0.id == tmpl.id } } else { selected.append(tmpl) }
        }
    }

    // MARK: — Save

    private func save() {
        let uid = authVM.currentUser?.id ?? authVM.userSession?.uid ?? ""
        guard !uid.isEmpty else { return }
        isSaving = true
        let exercises = selected.map { Exercise(name: $0.name, sets: $0.defaultSets, reps: $0.defaultReps) }
        let workout = Workout(
            title: title.isEmpty ? type.localizedName : title,
            type: type, duration: duration, calories: calories, date: Date(),
            userId: uid,
            videoURLs: videoURLs.filter { !$0.isEmpty },
            exercises: exercises
        )
        Task {
            await workoutVM.addWorkout(workout, userId: uid)
            await MainActor.run { isSaving = false; dismiss() }
        }
    }

    // MARK: — Form Section

    @ViewBuilder
    private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium)).foregroundColor(AppTheme.muted).padding(.leading, 4)
            VStack(spacing: 0) { content() }
                .background(AppTheme.card).cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
        }
    }

    // MARK: — Text Field

    private func locTextField(
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        TextField("", text: text)
            .placeholder(when: text.wrappedValue.isEmpty) {
                Text(placeholder).foregroundColor(AppTheme.muted)
            }
            .foregroundColor(.white).font(.system(size: 15))
            .keyboardType(keyboard)
            .textInputAutocapitalization(keyboard == .URL ? .never : .sentences)
            .autocorrectionDisabled(keyboard == .URL)
            .padding(.horizontal, 16).padding(.vertical, 14)
    }

    // MARK: — Stepper

    private func customStepper(
        label: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        step: Int,
        unit: String,
        formatter: ((Int) -> String)? = nil
    ) -> some View {
        HStack {
            Text(label).font(.system(size: 15)).foregroundColor(.white)
            Spacer()
            HStack(spacing: 14) {
                Button {
                    if value.wrappedValue - step >= range.lowerBound { value.wrappedValue -= step }
                } label: {
                    Image(systemName: "minus.circle.fill").font(.system(size: 24)).foregroundColor(AppTheme.lime)
                }
                Text(formatter?(value.wrappedValue) ?? "\(value.wrappedValue) \(unit)")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    .frame(minWidth: 80, alignment: .center)
                Button {
                    if value.wrappedValue + step <= range.upperBound { value.wrappedValue += step }
                } label: {
                    Image(systemName: "plus.circle.fill").font(.system(size: 24)).foregroundColor(AppTheme.lime)
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}
