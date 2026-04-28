//
//   WorkoutViewModel.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

//  WorkoutViewModel.swift

import Foundation
import Combine
import Firebase
import FirebaseFirestore

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()

   
    func fetchWorkouts(userId: String) async {
        DispatchQueue.main.async { self.isLoading = true }
        do {
            let snap = try await db.collection("workouts")
                .whereField("userId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .getDocuments()

            let loaded = snap.documents.compactMap { doc -> Workout? in
                let d = doc.data()
                guard let title = d["title"] as? String,
                      let typeRaw = d["type"] as? String,
                      let type = Workout.WorkoutType(rawValue: typeRaw),
                      let duration = d["duration"] as? Int,
                      let calories = d["calories"] as? Int,
                      let userId = d["userId"] as? String
                else { return nil }

                let date = (d["date"] as? Timestamp)?.dateValue() ?? Date()
                let videoURLs = d["videoURLs"] as? [String] ?? []

                let exercisesData = d["exercises"] as? [[String: Any]] ?? []
                let exercises = exercisesData.compactMap { e -> Exercise? in
                    guard let name = e["name"] as? String else { return nil }
                    return Exercise(
                        id: e["id"] as? String ?? UUID().uuidString,
                        name: name,
                        sets: e["sets"] as? Int ?? 3,
                        reps: e["reps"] as? Int ?? 10,
                        weight: e["weight"] as? Double
                    )
                }

                return Workout(
                    id: doc.documentID,
                    title: title,
                    type: type,
                    duration: duration,
                    calories: calories,
                    date: date,
                    userId: userId,
                    videoURLs: videoURLs,
                    exercises: exercises
                )
            }
            DispatchQueue.main.async {
                self.workouts = loaded
                self.isLoading = false
            }
        } catch {
            print("Ошибка загрузки: \(error.localizedDescription)")
            DispatchQueue.main.async { self.isLoading = false }
        }
    }

    
    func addWorkout(_ workout: Workout, userId: String) async {
        var data: [String: Any] = [
            "title": workout.title,
            "type": workout.type.rawValue,
            "duration": workout.duration,
            "calories": workout.calories,
            "date": Timestamp(date: workout.date),
            "userId": userId
        ]
        
        data["videoURLs"] = workout.videoURLs
        
        let exercisesData: [[String: Any]] = workout.exercises.map { ex in
            var e: [String: Any] = [
                "id": ex.id,
                "name": ex.name,
                "sets": ex.sets,
                "reps": ex.reps
            ]
            if let w = ex.weight { e["weight"] = w }
            return e
        }
        data["exercises"] = exercisesData

        do {
            try await db.collection("workouts").addDocument(data: data)
            await fetchWorkouts(userId: userId)
        } catch {
            print("Ошибка добавления: \(error.localizedDescription)")
        }
    }

    func deleteWorkout(_ workout: Workout, userId: String) async {
        guard let id = workout.id else { return }
        try? await db.collection("workouts").document(id).delete()
        DispatchQueue.main.async {
            self.workouts.removeAll { $0.id == id }
        }
    }

    var totalWorkouts: Int { workouts.count }
    var totalCalories: Int { workouts.reduce(0) { $0 + $1.calories } }
    var totalMinutes: Int  { workouts.reduce(0) { $0 + $1.duration } }

    var workoutsThisWeek: [Workout] {
        let cal = Calendar.current
        guard let start = cal.date(
            from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) else { return [] }
        return workouts.filter { $0.date >= start }
    }

    var caloriesByType: [(type: String, calories: Int)] {
        let grouped = Dictionary(grouping: workouts, by: { $0.type.localizedName})
        return grouped.map { (type: $0.key, calories: $0.value.reduce(0) { $0 + $1.calories }) }
            .sorted { $0.calories > $1.calories }
    }

    var last7DaysWorkouts: [(date: String, count: Int)] {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return (0..<7).reversed().map { offset -> (String, Int) in
            let date = cal.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let label = formatter.string(from: date)
            let count = workouts.filter { cal.isDate($0.date, inSameDayAs: date) }.count
            return (label, count)
        }
    }
}
