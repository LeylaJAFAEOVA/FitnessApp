//
//  FitnessApp.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct FitnessApp: App {
    @StateObject var authVM = AuthViewModel()
    @AppStorage("app_language") private var language = "en"

    init() {
        let savedLang = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        Bundle.setLanguage(savedLang)
    
        FirebaseApp.configure()
        UserDefaults.standard.set(false, forKey: "WebKitDeveloperExtras")
        URLSession.shared.configuration.waitsForConnectivity = true
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .id(language)
                .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
