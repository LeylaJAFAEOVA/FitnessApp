//
//  WorkoutDetailView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 02/04/2026.
//

import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let urlString: String
    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.scrollView.isScrollEnabled = false
        wv.backgroundColor = .black
        return wv
    }
    func updateUIView(_ webView: WKWebView, context: Context) {
        var videoID = ""
        
        if urlString.contains("watch?v=") {
            videoID = urlString.components(separatedBy: "watch?v=").last?
                .components(separatedBy: "&").first ?? ""
        } else if urlString.contains("youtu.be/") {
            videoID = urlString.components(separatedBy: "youtu.be/").last?
                .components(separatedBy: "?").first ?? ""
        } else if urlString.contains("embed/") {
            videoID = urlString.components(separatedBy: "embed/").last ?? ""
        }
        
        guard !videoID.isEmpty,
              let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1")
        else { return }
        
        webView.load(URLRequest(url: url))
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    @EnvironmentObject var authVM:    AuthViewModel
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @Environment(\.dismiss) var dismiss

    @State private var videoExpanded = false

    var body: some View {
        ZStack {
            AppTheme.dark.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection
                    statsStrip
                    if let url = workout.videoURLs.first, !url.isEmpty {
                        videoSection(url)
                    }
                    if !workout.exercises.isEmpty { exercisesSection }
                    startButton
                    Spacer(minLength: 50)
                }
            }
        }
        .navigationTitle(LocalizedStringKey("detail.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(AppTheme.dark, for: .navigationBar)
    }

    // MARK: — Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            thumbnailOrGradient.frame(maxWidth: .infinity).frame(height: 250).clipped()

            LinearGradient(
                colors: [AppTheme.dark, AppTheme.dark.opacity(0.4), .clear],
                startPoint: .bottom, endPoint: .top
            )

            // Duration badge
            VStack {
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.system(size: 10))
                        Text("\(workout.duration) \(NSLocalizedString("detail.min", comment: ""))")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.lime)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(AppTheme.lime.opacity(0.15))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.lime.opacity(0.4), lineWidth: 1))
                    .cornerRadius(20)
                }
                Spacer()
            }.padding(16)

            // Play / Pause button
            if !workout.videoURLs.isEmpty {
                Button { withAnimation(.easeInOut) { videoExpanded.toggle() } } label: {
                    ZStack {
                        Circle().stroke(AppTheme.lime.opacity(0.25), lineWidth: 2).frame(width: 72, height: 72)
                        Circle().fill(AppTheme.lime).frame(width: 52, height: 52)
                        Image(systemName: videoExpanded ? "pause.fill" : "play.fill")
                            .font(.system(size: 18)).foregroundColor(.black)
                            .offset(x: videoExpanded ? 0 : 2)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity).padding(.bottom, 50)
            }

            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title).font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                Text(workout.type.localizedName).font(.system(size: 13)).foregroundColor(AppTheme.muted)
            }
            .padding(.horizontal, 20).padding(.bottom, 18)
        }
        .frame(height: 250)
    }

    @ViewBuilder
    private var thumbnailOrGradient: some View {
        if let url = workout.videoURLs.first,
           let thumb = youtubeThumbnailURL(from: url) {
            AsyncImage(url: thumb) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { gradientHero }
            }
        } else { gradientHero }
    }

    private var gradientHero: some View {
        ZStack {
            AppTheme.gradient(for: workout.type)
            Image(systemName: workout.type.icon).font(.system(size: 60))
                .foregroundColor(AppTheme.color(for: workout.type).opacity(0.2))
        }
    }

    // MARK: — Stats strip

    private var statsStrip: some View {
        HStack(spacing: 0) {
            statCell(icon: "clock",      label: "\(workout.duration)",
                     unit: NSLocalizedString("detail.min", comment: ""),  color: .blue)
            Rectangle().fill(AppTheme.border).frame(width: 1, height: 38)
            statCell(icon: "flame.fill", label: "\(workout.calories)",
                     unit: NSLocalizedString("detail.kcal", comment: ""), color: .orange)
            Rectangle().fill(AppTheme.border).frame(width: 1, height: 38)
            statCell(icon: "calendar",   label: formattedDate(workout.date), unit: "",  color: AppTheme.lime)
        }
        .padding(.vertical, 14)
        .background(AppTheme.card)
        .overlay(Rectangle().stroke(AppTheme.border, lineWidth: 1))
    }

    private func statCell(icon: String, label: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 18))
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(label).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                if !unit.isEmpty { Text(unit).font(.system(size: 10)).foregroundColor(AppTheme.muted) }
            }
        }.frame(maxWidth: .infinity)
    }

    // MARK: — Video

    private func videoSection(_ url: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(NSLocalizedString("detail.video", comment: ""), icon: "play.rectangle.fill")
                .padding(.top, 22)
            if videoExpanded {
                YouTubePlayerView(urlString: url)
                    .frame(height: 220).cornerRadius(16).padding(.horizontal, 20)
            } else {
                Button { withAnimation { videoExpanded = true } } label: {
                    ZStack {
                        thumbnailOrGradient.frame(maxWidth: .infinity).frame(height: 200).clipped()
                        Color.black.opacity(0.3)
                        ZStack {
                            Circle().stroke(AppTheme.lime.opacity(0.3), lineWidth: 2).frame(width: 60, height: 60)
                            Circle().fill(AppTheme.lime).frame(width: 44, height: 44)
                            Image(systemName: "play.fill").font(.system(size: 16))
                                .foregroundColor(.black).offset(x: 2)
                        }
                    }
                    .cornerRadius(16).clipped()
                }
                .buttonStyle(.plain).padding(.horizontal, 20)
            }
        }
    }

    // MARK: — Exercises

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(NSLocalizedString("detail.exercises", comment: ""), icon: "list.bullet.clipboard")
                .padding(.top, 22)
            VStack(spacing: 8) {
                ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { idx, ex in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(idx == 0 ? AppTheme.lime : AppTheme.card2).frame(width: 32, height: 32)
                            Text("\(idx + 1)").font(.system(size: 12, weight: .bold))
                                .foregroundColor(idx == 0 ? .black : AppTheme.muted)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(ex.name).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            Text(
                                "\(ex.sets) \(NSLocalizedString("detail.sets", comment: "")) × " +
                                "\(ex.reps) \(NSLocalizedString("detail.reps", comment: ""))"
                            )
                            .font(.system(size: 11)).foregroundColor(AppTheme.muted)
                        }
                        Spacer()
                        if let w = ex.weight {
                            Text("\(Int(w)) \(NSLocalizedString("profile.kg", comment: ""))")
                                .font(.system(size: 11, weight: .bold)).foregroundColor(AppTheme.lime)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(AppTheme.lime.opacity(0.1)).cornerRadius(8)
                        }
                        Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(AppTheme.muted)
                    }
                    .padding(14).background(AppTheme.card).cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: — Start button

    private var startButton: some View {
        Button {} label: {
            Text(LocalizedStringKey("detail.lets_workout"))
                .font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(AppTheme.lime).cornerRadius(100)
        }
        .padding(.horizontal, 20).padding(.top, 24)
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(AppTheme.lime).font(.system(size: 14))
            Text(title).font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
        }.padding(.horizontal, 20)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "dd.MM.yy"; return f.string(from: date)
    }
}

struct StatPill: View {
    let icon: String; let value: String; let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(.caption.bold())
        }.frame(maxWidth: .infinity).padding(.vertical, 10)
    }
}
