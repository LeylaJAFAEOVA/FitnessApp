//
//  StatsView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.dark.ignoresSafeArea()
                if workoutVM.workouts.isEmpty { emptyState }
                else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            statCards
                            barChartSection
                            pieChartSection
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("tab.stats", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.dark, for: .navigationBar)
        }
    }

    // MARK: — 4 Stat cards

    private var statCards: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            DarkStatCard(
                title: NSLocalizedString("stats.workouts", comment: ""),
                value: "\(workoutVM.totalWorkouts)",
                icon: "dumbbell.fill", color: AppTheme.lime
            )
            DarkStatCard(
                title: NSLocalizedString("stats.calories", comment: ""),
                value: "\(workoutVM.totalCalories)",
                icon: "flame.fill", color: .orange
            )
            DarkStatCard(
                title: NSLocalizedString("stats.minutes", comment: ""),
                value: "\(workoutVM.totalMinutes)",
                icon: "clock.fill", color: Color(hex: "#A855F7")
            )
            DarkStatCard(
                title: NSLocalizedString("stats.this_week", comment: ""),
                value: "\(workoutVM.workoutsThisWeek.count)",
                icon: "calendar", color: Color(hex: "#4D9FFF")
            )
        }
    }

    // MARK: — Bar chart

    @ViewBuilder
    private var barChartSection: some View {
        if !workoutVM.workouts.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(NSLocalizedString("stats.last7days", comment: ""), icon: "chart.bar.fill")

                if #available(iOS 16.0, *) {
                    Chart(workoutVM.last7DaysWorkouts, id: \.date) { item in
                        BarMark(
                            x: .value("Day", item.date),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.lime, AppTheme.lime.opacity(0.4)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .cornerRadius(6)
                    }
                    .frame(height: 180)
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel().foregroundStyle(AppTheme.muted)
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(AppTheme.border)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .stride(by: 1)) { _ in
                            AxisValueLabel().foregroundStyle(AppTheme.muted)
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(AppTheme.border)
                        }
                    }
                    .chartPlotStyle { $0.background(Color.clear) }
                }
            }
            .padding(16)
            .background(AppTheme.card).cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border, lineWidth: 1))
        }
    }

    // MARK: — Pie chart

    @ViewBuilder
    private var pieChartSection: some View {
        if !workoutVM.caloriesByType.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(NSLocalizedString("stats.calories_by_type", comment: ""), icon: "chart.pie.fill")

                if #available(iOS 16.0, *) {
                    Chart(workoutVM.caloriesByType, id: \.type) { item in
                        SectorMark(
                            angle: .value("kcal", item.calories),
                            innerRadius: .ratio(0.52),
                            angularInset: 2
                        )
                        .foregroundStyle(colorForType(item.type))
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                }

                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(workoutVM.caloriesByType, id: \.type) { item in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(colorForType(item.type)).frame(width: 12, height: 12)
                            Text(item.type).font(.system(size: 13)).foregroundColor(.white)
                            Spacer()
                            Text("\(item.calories) \(NSLocalizedString("workouts.kcal", comment: ""))")
                                .font(.system(size: 13, weight: .semibold)).foregroundColor(AppTheme.lime)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(AppTheme.card).cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border, lineWidth: 1))
        }
    }

    // MARK: — Empty

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(AppTheme.lime.opacity(0.1)).frame(width: 90, height: 90)
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 40)).foregroundColor(AppTheme.lime.opacity(0.6))
            }
            Text(NSLocalizedString("stats.no_data", comment: ""))
                .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Text(NSLocalizedString("stats.no_data_sub", comment: ""))
                .font(.system(size: 14)).foregroundColor(AppTheme.muted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: — Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(AppTheme.lime).font(.system(size: 14))
            Text(title).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
        }
    }

    private func colorForType(_ type: String) -> Color {
        switch type {
        case "Кардио","Cardio","Kardio":   return Color(hex: "#FF4D4D")
        case "Силовая","Strength":         return Color(hex: "#4D9FFF")
        case "Йога","Yoga":               return Color(hex: "#A855F7")
        case "HIIT":                       return Color(hex: "#FF8C00")
        case "Бег","Running":             return Color(hex: "#22C55E")
        default:                           return AppTheme.muted
        }
    }
}

// MARK: — DarkStatCard

struct DarkStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.15)).frame(width: 38, height: 38)
                Image(systemName: icon).font(.system(size: 17)).foregroundColor(color)
            }
            Text(value).font(.system(size: 28, weight: .bold)).foregroundColor(.white)
            Text(title).font(.system(size: 12)).foregroundColor(AppTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(16)
        .background(AppTheme.card).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border, lineWidth: 1))
    }
}

struct StatCard: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View { DarkStatCard(title: title, value: value, icon: icon, color: color) }
}
