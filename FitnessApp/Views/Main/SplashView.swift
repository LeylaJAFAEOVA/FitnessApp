//
//  SplashView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 26/04/2026.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale:   CGFloat = 0.6
    @State private var logoOpacity: Double  = 0
    @State private var textOpacity: Double  = 0
    @State private var ringTrim:    CGFloat = 0

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 20) {
               
                ZStack {
                    Circle()
                        .stroke(AppTheme.lime.opacity(0.15), lineWidth: 3)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: ringTrim)
                        .stroke(AppTheme.lime, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: ringTrim)

                    ZStack {
                        Circle()
                            .fill(AppTheme.lime.opacity(0.15))
                            .frame(width: 90, height: 90)
                        Image(systemName: "bolt.heart.fill")
                            .font(.system(size: 38))
                            .foregroundColor(AppTheme.lime)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                }

                VStack(spacing: 4) {
                    Text("PULSE")
                        .font(.system(size: 34, weight: .black))
                        .foregroundColor(.white)
                    Text(NSLocalizedString("login.title", comment: ""))
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.muted)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale   = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                textOpacity = 1.0
            }
            ringTrim = 1.0
        }
    }
}
