//
//  LoginView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email    = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.dark.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {

                        // Logo
                        VStack(spacing: 12) {
                            ZStack {
                                Circle().fill(AppTheme.lime.opacity(0.15)).frame(width: 90, height: 90)
                                Image(systemName: "bolt.heart.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.lime)
                            }
                            Text("PULSE")
                                .font(.system(size: 36, weight: .black))
                                .foregroundColor(.white)
                            Text(NSLocalizedString("login.title", comment: ""))
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.muted)
                        }
                        .padding(.top, 60)

                        // Fields
                        VStack(spacing: 14) {
                            DarkTextField(
                                icon: "envelope",
                                placeholder: NSLocalizedString("login.email", comment: ""),
                                text: $email
                            )
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                            DarkTextField(
                                icon: "lock",
                                placeholder: NSLocalizedString("login.password", comment: ""),
                                text: $password,
                                isSecure: true
                            )

                            if !authVM.errorMessage.isEmpty {
                                Text(authVM.errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        // Buttons
                        VStack(spacing: 12) {

                            // Email login
                            Button {
                                Task { await authVM.login(email: email, password: password) }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 100)
                                        .fill(AppTheme.lime)
                                        .frame(height: 54)
                                    if authVM.isLoading {
                                        ProgressView().tint(.black)
                                    } else {
                                        Text(NSLocalizedString("login.signin", comment: ""))
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)

                            // Divider
                            HStack {
                                Rectangle().fill(AppTheme.border).frame(height: 1)
                                Text("or").font(.system(size: 12)).foregroundColor(AppTheme.muted)
                                Rectangle().fill(AppTheme.border).frame(height: 1)
                            }

                            // Google login
                            Button {
                                Task { await authVM.signInWithGoogle() }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                    Text(NSLocalizedString("login.google", comment: ""))
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#4285F4"))
                                .cornerRadius(100)
                            }

                            // Register
                            Button { showRegister = true } label: {
                                Text(NSLocalizedString("login.no_account", comment: ""))
                                    .foregroundColor(AppTheme.muted) +
                                Text(NSLocalizedString("login.register", comment: ""))
                                    .foregroundColor(AppTheme.lime)
                            }
                            .font(.system(size: 14))
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

struct DarkTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.muted)
                .frame(width: 20)
            if isSecure {
                SecureField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder).foregroundColor(AppTheme.muted)
                    }
                    .foregroundColor(.white)
            } else {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder).foregroundColor(AppTheme.muted)
                    }
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(AppTheme.card)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 1))
    }
}
