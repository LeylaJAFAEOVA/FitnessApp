//
//  RegisterView.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var confirm  = ""

    private var passwordsMatch: Bool { password == confirm }
    private var formValid: Bool {
        !name.isEmpty && !email.isEmpty && password.count >= 6 && passwordsMatch
    }

    var body: some View {
        ZStack {
            AppTheme.dark.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.muted)
                                .padding(10)
                                .background(AppTheme.card)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .padding(.top, 16)

                    // Logo
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().fill(AppTheme.lime.opacity(0.15)).frame(width: 80, height: 80)
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 34))
                                .foregroundColor(AppTheme.lime)
                        }
                        Text("Создать аккаунт")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }

                    // Fields
                    VStack(spacing: 14) {
                        DarkTextField(icon: "person", placeholder: "Имя", text: $name)
                        DarkTextField(icon: "envelope", placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        DarkTextField(icon: "lock", placeholder: "Пароль (мин. 6 символов)", text: $password, isSecure: true)
                        DarkTextField(icon: "lock.fill", placeholder: "Подтвердите пароль", text: $confirm, isSecure: true)

                        if !confirm.isEmpty && !passwordsMatch {
                            Text("Пароли не совпадают")
                                .font(.caption).foregroundColor(.red)
                        }
                        if !authVM.errorMessage.isEmpty {
                            Text(authVM.errorMessage)
                                .font(.caption).foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }

                    // Button
                    Button {
                        Task { await authVM.register(name: name, email: email, password: password) }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 100)
                                .fill(formValid ? AppTheme.lime : AppTheme.card)
                                .frame(height: 54)
                            if authVM.isLoading {
                                ProgressView().tint(formValid ? .black : AppTheme.muted)
                            } else {
                                Text("Зарегистрироваться")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(formValid ? .black : AppTheme.muted)
                            }
                        }
                    }
                    .disabled(!formValid || authVM.isLoading)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
