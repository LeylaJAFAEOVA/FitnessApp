//
//  ProfileView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM:    AuthViewModel
    @EnvironmentObject var workoutVM: WorkoutViewModel

    @State private var weightText = ""
    @State private var heightText = ""
    @State private var isEditing  = false
    @State private var isSaving   = false

    // Persists language choice across launches
    @AppStorage("app_language") private var storedLang = "en"

    private let languages: [(code: String, name: String, flag: String)] = [
        ("en", "English",      "🇬🇧"),
        ("ru", "Русский",      "🇷🇺"),
        ("az-Cyrl", "Azərbaycan",   "🇦🇿")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.dark.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        avatarCard
                        bodyStatsCard
                        achievementsCard
                        languageCard
                        signOutButton
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 30)
                }
            }
            .navigationTitle(NSLocalizedString("profile.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if isSaving {
                        ProgressView().tint(AppTheme.lime)
                    } else {
                        Button(
                            isEditing
                                ? NSLocalizedString("profile.save", comment: "")
                                : NSLocalizedString("profile.edit", comment: "")
                        ) { handleEdit() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.lime)
                    }
                }
            }
        }
    }

    // MARK: — Avatar card

    private var avatarCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(AppTheme.lime).frame(width: 60, height: 60)
                Text(String(authVM.currentUser?.name.prefix(2).uppercased() ?? "FP"))
                    .font(.system(size: 20, weight: .bold)).foregroundColor(.black)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(authVM.currentUser?.name ?? "—")
                    .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                Text(authVM.currentUser?.email ?? "")
                    .font(.system(size: 13)).foregroundColor(AppTheme.muted)
            }
            Spacer()
        }
        .padding(18)
        .background(AppTheme.card).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border, lineWidth: 1))
    }

    // MARK: — Body stats

    private var bodyStatsCard: some View {
        cardSection(NSLocalizedString("profile.body_stats", comment: "")) {
            if isEditing {
                editRow(
                    label: NSLocalizedString("profile.weight", comment: ""),
                    placeholder: NSLocalizedString("profile.weight_placeholder", comment: ""),
                    text: $weightText
                )
                Divider().background(AppTheme.border)
                editRow(
                    label: NSLocalizedString("profile.height", comment: ""),
                    placeholder: NSLocalizedString("profile.height_placeholder", comment: ""),
                    text: $heightText
                )
            } else {
                infoRow(
                    label: NSLocalizedString("profile.weight", comment: ""),
                    value: authVM.currentUser?.weight.map { w in
                        let unit = NSLocalizedString("profile.kg", comment: "")
                        return w.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(w)) \(unit)" : "\(w) \(unit)"
                    } ?? "—"
                )
                Divider().background(AppTheme.border)
                infoRow(
                    label: NSLocalizedString("profile.height", comment: ""),
                    value: authVM.currentUser?.height.map { h in
                        let unit = NSLocalizedString("profile.cm", comment: "")
                        return h.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(h)) \(unit)" : "\(h) \(unit)"
                    } ?? "—"
                )
                if let bmi = authVM.currentUser?.bmi {
                    Divider().background(AppTheme.border)
                    infoRow(
                        label: NSLocalizedString("profile.bmi", comment: ""),
                        value: String(format: "%.1f", bmi),
                        valueColor: bmiColor(bmi)
                    )
                }
            }
        }
    }

    // MARK: — Achievements

    private var achievementsCard: some View {
        cardSection(NSLocalizedString("profile.achievements", comment: "")) {
            achieveRow(
                icon: "dumbbell.fill", color: AppTheme.lime,
                label: NSLocalizedString("profile.total_workouts", comment: ""),
                value: "\(workoutVM.totalWorkouts)"
            )
            Divider().background(AppTheme.border)
            achieveRow(
                icon: "flame.fill", color: .orange,
                label: NSLocalizedString("profile.calories_burned", comment: ""),
                value: "\(workoutVM.totalCalories) \(NSLocalizedString("profile.kcal", comment: ""))"
            )
            Divider().background(AppTheme.border)
            achieveRow(
                icon: "calendar", color: Color(hex: "#4D9FFF"),
                label: NSLocalizedString("profile.this_week", comment: ""),
                value: "\(workoutVM.workoutsThisWeek.count)"
            )
        }
    }

    // MARK: — Language picker

    private var languageCard: some View {
        cardSection(NSLocalizedString("profile.language", comment: "")) {
            ForEach(Array(languages.enumerated()), id: \.element.code) { idx, lang in
                if idx > 0 { Divider().background(AppTheme.border) }
                Button {
                    storedLang = lang.code
                    // Trigger UI update — full restart needed for system locale,
                    // but strings refresh instantly via Bundle.main
                    Bundle.setLanguage(lang.code)
                } label: {
                    HStack(spacing: 12) {
                        Text(lang.flag).font(.system(size: 22))
                        Text(lang.name).font(.system(size: 15)).foregroundColor(.white)
                        Spacer()
                        if storedLang == lang.code {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.lime).font(.system(size: 18))
                        } else {
                            Circle().stroke(AppTheme.border, lineWidth: 1.5).frame(width: 18, height: 18)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                }
            }
        }
    }

    // MARK: — Sign out

    private var signOutButton: some View {
        Button {
            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
            authVM.signOut()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 16))
                Text(NSLocalizedString("profile.sign_out", comment: "")).font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(Color.red.opacity(0.08)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.25), lineWidth: 1))
        }
        .padding(.top, 4)
    }

    // MARK: — Reusable builders

    @ViewBuilder
    private func cardSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium)).foregroundColor(AppTheme.muted).padding(.leading, 4)
            VStack(spacing: 0) { content() }
                .background(AppTheme.card).cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1))
        }
    }

    private func infoRow(label: String, value: String, valueColor: Color = AppTheme.muted) -> some View {
        HStack {
            Text(label).font(.system(size: 15)).foregroundColor(.white)
            Spacer()
            Text(value).font(.system(size: 15)).foregroundColor(valueColor)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private func editRow(label: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Text(label).font(.system(size: 15)).foregroundColor(.white)
            Spacer()
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 15)).foregroundColor(AppTheme.lime)
                .frame(width: 120)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private func achieveRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.15)).frame(width: 32, height: 32)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            }
            Text(label).font(.system(size: 15)).foregroundColor(.white)
            Spacer()
            Text(value).font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.lime)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private func bmiColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18.5:  return Color(hex: "#4D9FFF")
        case 18.5..<25: return AppTheme.lime
        case 25..<30:  return .orange
        default:       return .red
        }
    }

    private func handleEdit() {
        if isEditing {
            isSaving = true
            let w = Double(weightText.replacingOccurrences(of: ",", with: "."))
            let h = Double(heightText.replacingOccurrences(of: ",", with: "."))
            Task {
                await authVM.updateProfile(weight: w, height: h)
                await MainActor.run { isSaving = false; isEditing = false }
            }
        } else {
            weightText = authVM.currentUser?.weight.map { String($0) } ?? ""
            heightText = authVM.currentUser?.height.map { String($0) } ?? ""
            isEditing = true
        }
    }
}

// MARK: — Bundle language switcher (instant, no restart needed)

extension Bundle {
    private static var bundleKey: UInt8 = 0

    static func setLanguage(_ language: String) {
        defer { object_setClass(Bundle.main, PrivateBundle.self) }
        objc_setAssociatedObject(
            Bundle.main, &bundleKey,
            language, .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    final class PrivateBundle: Bundle, @unchecked Sendable {
        override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
            guard
                let lang = objc_getAssociatedObject(Bundle.main, &Bundle.bundleKey) as? String
            else {
                return super.localizedString(forKey: key, value: value, table: tableName)
            }

            // Пробуем lang → Base → fallback
            let candidates = [lang, "Base"]
            for code in candidates {
                if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
                   let bundle = Bundle(path: path) {
                    let result = bundle.localizedString(forKey: key, value: nil, table: tableName)
                    if result != key { return result }
                }
            }
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}
// Backward compat
struct ProfileRow: View {
    let label: String; let value: String
    var body: some View {
        HStack { Text(label); Spacer(); Text(value).foregroundStyle(.secondary) }
    }
}
