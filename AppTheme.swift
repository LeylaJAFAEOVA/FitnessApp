//
//  AppTheme.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 05/04/2026.
//


import SwiftUI

// MARK: — Design tokens

enum AppTheme {
    static let lime   = Color(hex: "#C8FF00")
    static let dark   = Color(hex: "#0A0A0A")
    static let card   = Color(hex: "#141414")
    static let card2  = Color(hex: "#1C1C1C")
    static let border = Color(hex: "#2A2A2A")
    static let muted  = Color(hex: "#888888")

    static func color(for type: Workout.WorkoutType) -> Color {
        switch type {
        case .cardio:   return Color(hex: "#FF4D4D")
        case .strength: return Color(hex: "#4D9FFF")
        case .yoga:     return Color(hex: "#A855F7")
        case .hiit:     return Color(hex: "#FF8C00")
        case .running:  return Color(hex: "#22C55E")
        }
    }

    static func gradient(for type: Workout.WorkoutType) -> LinearGradient {
        LinearGradient(
            colors: [color(for: type).opacity(0.30), color(for: type).opacity(0.05)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}

// MARK: — Color(hex:) initialiser

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch h.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6:  (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8:  (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default: (a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: — YouTube thumbnail URL helper

func youtubeThumbnailURL(from urlString: String) -> URL? {
    let patterns = [
        "watch\\?v=([a-zA-Z0-9_-]{11})",
        "youtu\\.be/([a-zA-Z0-9_-]{11})",
        "embed/([a-zA-Z0-9_-]{11})"
    ]
    for pattern in patterns {
        guard let range = urlString.range(of: pattern, options: .regularExpression) else { continue }
        let sub = String(urlString[range])
        if let idRange = sub.range(of: "[a-zA-Z0-9_-]{11}", options: .regularExpression) {
            let videoId = String(sub[idRange])
            return URL(string: "https://img.youtube.com/vi/\(videoId)/hqdefault.jpg")
        }
    }
    return nil
}

// MARK: — Placeholder helper for TextField

extension View {
    func placeholder<C: View>(when show: Bool, @ViewBuilder _ p: () -> C) -> some View {
        ZStack(alignment: .leading) { p().opacity(show ? 1 : 0); self }
    }
}
