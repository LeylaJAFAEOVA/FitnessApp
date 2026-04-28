//
//  AuthViewModel.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine
import GoogleSignIn
import GoogleSignInSwift
import UIKit

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isCheckingAuth = true

    init() {
        self.userSession = nil
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.userSession = user
                self?.isCheckingAuth = false
            }
            if user != nil {
                Task { await self?.fetchUser() }
            } else {
                DispatchQueue.main.async { self?.currentUser = nil }
            }
        }
    }

    func login(email: String, password: String) async {
        DispatchQueue.main.async { self.isLoading = true; self.errorMessage = "" }
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            DispatchQueue.main.async { self.userSession = result.user }
            await fetchUser()
        } catch {
            DispatchQueue.main.async { self.errorMessage = self.localizeError(error) }
        }
        DispatchQueue.main.async { self.isLoading = false }
    }

    func register(name: String, email: String, password: String) async {
        DispatchQueue.main.async { self.isLoading = true; self.errorMessage = "" }
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            DispatchQueue.main.async { self.userSession = result.user }
            let data: [String: Any] = [
                "id": result.user.uid,
                "name": name,
                "email": email,
                "joinDate": Timestamp(date: Date())
            ]
            try await Firestore.firestore()
                .collection("users")
                .document(result.user.uid)
                .setData(data)
            await fetchUser()
        } catch {
            DispatchQueue.main.async { self.errorMessage = self.localizeError(error) }
        }
        DispatchQueue.main.async { self.isLoading = false }
    }

    func resetPassword(email: String) async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            DispatchQueue.main.async {
                self.errorMessage = "Reset link sent to your email ✅"
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = self.localizeError(error)
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        DispatchQueue.main.async {
            self.userSession = nil
            self.currentUser = nil
        }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snap = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            guard let data = snap.data() else { return }
            let user = User(
                id: uid,
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                weight: data["weight"] as? Double,
                height: data["height"] as? Double
            )
            DispatchQueue.main.async { self.currentUser = user }
        } catch {
            print("fetchUser error: \(error.localizedDescription)")
        }
    }

    func updateProfile(weight: Double?, height: Double?) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var data: [String: Any] = [:]
        if let w = weight { data["weight"] = w }
        if let h = height { data["height"] = h }
        guard !data.isEmpty else { return }
        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData(data, merge: true)
            await fetchUser()
        } catch {
            print("updateProfile error: \(error.localizedDescription)")
        }
    }

    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootVC = await window.rootViewController else { return }

        DispatchQueue.main.async { self.isLoading = true }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            let user = result.user
            guard let idToken = user.idToken?.tokenString else { return }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            let authResult = try await Auth.auth().signIn(with: credential)

            let data: [String: Any] = [
                "id": authResult.user.uid,
                "name": user.profile?.name ?? "",
                "email": user.profile?.email ?? "",
                "photoURL": user.profile?.imageURL(withDimension: 200)?.absoluteString ?? ""
            ]
            try await Firestore.firestore()
                .collection("users")
                .document(authResult.user.uid)
                .setData(data, merge: true)

            DispatchQueue.main.async { self.userSession = authResult.user }
            await fetchUser()
        } catch {
            DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
        }
        DispatchQueue.main.async { self.isLoading = false }
    }

    private func localizeError(_ error: Error) -> String {
        let err = error as NSError
        switch err.code {
        case 17009: return "Wrong password"
        case 17011: return "User not found"
        case 17007: return "Email already in use"
        case 17026: return "Password is too weak (min. 6 characters)"
        case 17008: return "Invalid email"
        default:    return error.localizedDescription
        }
    }
}
