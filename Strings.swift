//
//  Strings.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 02/04/2026.
//

import Foundation

struct Strings {
    // MARK: — Auth
    struct Auth {
        static let appTagline      = "Your personal trainer"
        static let email           = "Email"
        static let password        = "Password"
        static let signIn          = "Sign In"
        static let noAccount       = "Don't have an account? Sign Up"
        static let createAccount   = "Create Account"
        static let fullName        = "Full Name"
        static let passwordMin     = "Password (min. 6 characters)"
        static let confirmPassword = "Confirm Password"
        static let passwordNoMatch = "Passwords don't match"
        static let close           = "Close"
    }

    // MARK: — Tabs
    struct Tabs {
        static let workouts = "Workouts"
        static let progress = "Progress"
        static let profile  = "Profile"
    }

    // MARK: — Workouts
    struct Workouts {
        static let title        = "Workouts"
        static let loading      = "Loading..."
        static let noWorkouts   = "No Workouts Yet"
        static let noWorkoutsSub = "Tap + to add your first workout"
        static let exercises    = "exercises"
        static let min          = "min"
        static let kcal         = "kcal"
    }

    // MARK: — Add Workout
    struct AddWorkout {
        static let title        = "New Workout"
        static let general      = "General"
        static let name         = "Workout name"
        static let type         = "Type"
        static let parameters   = "Parameters"
        static let duration     = "Duration"
        static let calories     = "Calories"
        static let video        = "Video (YouTube link)"
        static let videoPlaceholder = "https://youtube.com/..."
        static let exercises    = "Exercises"
        static let selected     = "selected"
        static let sets         = "sets"
        static let reps         = "reps"
        static let cancel       = "Cancel"
        static let save         = "Save"
        static let saving       = "Saving..."
    }

    // MARK: — Stats
    struct Stats {
        static let title          = "Progress"
        static let totalWorkouts  = "Workouts"
        static let totalCalories  = "Calories"
        static let totalMinutes   = "Minutes"
        static let thisWeek       = "This Week"
        static let last7Days      = "Workouts — Last 7 Days"
        static let caloriesByType = "Calories by Type"
        static let noData         = "No Data Yet"
        static let noDataSub      = "Add workouts to see your statistics"
        static let kcal           = "kcal"
    }

    // MARK: — Profile
    struct Profile {
        static let title          = "Profile"
        static let bodyStats      = "Body Stats"
        static let weight         = "Weight (kg)"
        static let height         = "Height (cm)"
        static let bmi            = "BMI"
        static let achievements   = "Achievements"
        static let totalWorkouts  = "Total Workouts"
        static let caloriesBurned = "Calories Burned"
        static let thisWeek       = "Workouts This Week"
        static let edit           = "Edit"
        static let save           = "Save"
        static let signOut        = "Sign Out"
        static let weightPlaceholder = "70"
        static let heightPlaceholder = "170"
        static let kg             = "kg"
        static let cm             = "cm"
        static let kcal           = "kcal"
    }

    // MARK: — Workout Types (English)
    struct WorkoutType {
        static let cardio   = "Cardio"
        static let strength = "Strength"
        static let yoga     = "Yoga"
        static let hiit     = "HIIT"
        static let running  = "Running"
    }
}

