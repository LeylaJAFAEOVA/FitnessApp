//
//  User.swift
//  FitnessApp
//
//  Created by Leyla Jafarova on 01/04/2026.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var weight: Double?
    var height: Double?
    var photoURL: String?
    var joinDate: Date = Date()

    var bmi: Double? {
        guard let w = weight, let h = height, h > 0 else { return nil }
        let hm = h / 100
        return w / (hm * hm)
    }
}
