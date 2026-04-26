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

                            
                            HStack {
                                Spacer()
                                Button {
                                    Task { await authVM.resetPassword(email: email) }
                                } label: {
                                    Text("Forgot password?")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.lime)
                                }
                                .disabled(email.isEmpty)
                            }

                            if !authVM.errorMessage.isEmpty {
                                Text(authVM.errorMessage)
                                    .font(.caption)
                                    .foregroundColor(
                                        authVM.errorMessage.contains("✅") ? .green : .red
                                    )
                                    .multilineTextAlignment(.center)
                            }
                        }

                        
                        VStack(spacing: 12) {

                          
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

                            
                            HStack {
                                Rectangle().fill(AppTheme.border).frame(height: 1)
                                Text("or").font(.system(size: 12)).foregroundColor(AppTheme.muted)
                                Rectangle().fill(AppTheme.border).frame(height: 1)
                            }

                            
                            HStack(spacing: 20) {
                    
                                Button {
                                    Task { await authVM.signInWithGoogle() }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.card)
                                            .frame(width: 54, height: 54)
                                            .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                                        Image("google")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 26, height: 26)
                                    }
                                }

                                
                                Button {
                                    // TODO: Facebook auth
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.card)
                                            .frame(width: 54, height: 54)
                                            .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                                        Image("facebook")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 26, height: 26)
                                    }
                                }
                            }

                           
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
    }
}
