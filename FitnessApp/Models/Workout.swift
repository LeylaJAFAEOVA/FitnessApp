//
//  Workout.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

import Foundation

struct Workout: Identifiable, Codable {
    var id: String?
    var title: String
    var type: WorkoutType
    var duration: Int
    var calories: Int
    var date: Date
    var userId: String
    var videoURLs: [String] = []
    var exercises: [Exercise] = []

    enum WorkoutType: String, Codable, CaseIterable {
       
        case cardio   = "Кардио"
        case strength = "Силовая"
        case yoga     = "Йога"
        case hiit     = "HIIT"
        case running  = "Бег"

       
        var localizedName: String {
            switch self {
            case .cardio:   return NSLocalizedString("workout.type.cardio",   comment: "")
            case .strength: return NSLocalizedString("workout.type.strength", comment: "")
            case .yoga:     return NSLocalizedString("workout.type.yoga",     comment: "")
            case .hiit:     return NSLocalizedString("workout.type.hiit",     comment: "")
            case .running:  return NSLocalizedString("workout.type.running",  comment: "")
            }
        }

        var icon: String {
            switch self {
            case .cardio:   return "heart.fill"
            case .strength: return "dumbbell.fill"
            case .yoga:     return "figure.yoga"
            case .hiit:     return "bolt.fill"
            case .running:  return "figure.run"
            }
        }

        var color: String {
            switch self {
            case .cardio:   return "red"
            case .strength: return "blue"
            case .yoga:     return "purple"
            case .hiit:     return "orange"
            case .running:  return "green"
            }
        }
    }
}

struct Exercise: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var sets: Int
    var reps: Int
    var weight: Double?
}



struct ExerciseTemplate: Identifiable {
    let id = UUID()
    let nameKey: String
    let type: Workout.WorkoutType
    let defaultSets: Int
    let defaultReps: Int
    let videoURL: String?


    var name: String {
        NSLocalizedString(nameKey, comment: "")
    }

    static let all: [ExerciseTemplate] = [

       
        ExerciseTemplate(nameKey: "exercise.bench_press",      type: .strength, defaultSets: 4, defaultReps: 10, videoURL: "https://www.youtube.com/watch?v=rT7DgCr-3pg"),
        ExerciseTemplate(nameKey: "exercise.squats",           type: .strength, defaultSets: 4, defaultReps: 12, videoURL: "https://www.youtube.com/watch?v=aclHkVaku9U"),
        ExerciseTemplate(nameKey: "exercise.deadlift",         type: .strength, defaultSets: 3, defaultReps: 8,  videoURL: "https://www.youtube.com/watch?v=op9kVnSso6Q"),
        ExerciseTemplate(nameKey: "exercise.pull_ups",         type: .strength, defaultSets: 3, defaultReps: 8,  videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.push_ups",         type: .strength, defaultSets: 3, defaultReps: 15, videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.plank",            type: .strength, defaultSets: 3, defaultReps: 60, videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.dumbbell_press",   type: .strength, defaultSets: 3, defaultReps: 12, videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.row",              type: .strength, defaultSets: 3, defaultReps: 10, videoURL: nil),

        
        ExerciseTemplate(nameKey: "exercise.jump_rope",        type: .cardio,   defaultSets: 3, defaultReps: 100, videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.burpees",          type: .cardio,   defaultSets: 3, defaultReps: 10,  videoURL: "https://www.youtube.com/watch?v=dZgVxmf6jkA"),
        ExerciseTemplate(nameKey: "exercise.running_in_place", type: .cardio,   defaultSets: 3, defaultReps: 60,  videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.jumping_jacks",    type: .cardio,   defaultSets: 3, defaultReps: 20,  videoURL: nil),

        
        ExerciseTemplate(nameKey: "exercise.mountain_climber", type: .hiit,     defaultSets: 4, defaultReps: 30, videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.box_jumps",        type: .hiit,     defaultSets: 3, defaultReps: 10, videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.jump_lunges",      type: .hiit,     defaultSets: 3, defaultReps: 12, videoURL: nil),

        
        ExerciseTemplate(nameKey: "exercise.downward_dog",     type: .yoga,     defaultSets: 1, defaultReps: 60, videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.warrior_pose",     type: .yoga,     defaultSets: 2, defaultReps: 30, videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.child_pose",       type: .yoga,     defaultSets: 1, defaultReps: 60, videoURL: nil),

       
        ExerciseTemplate(nameKey: "exercise.easy_run",         type: .running,  defaultSets: 1, defaultReps: 1, videoURL: nil),
        ExerciseTemplate(nameKey: "exercise.interval_run",     type: .running,  defaultSets: 6, defaultReps: 1, videoURL: nil),
    ]
}
