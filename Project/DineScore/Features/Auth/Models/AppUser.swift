//
//  User.swift
//  DineScore
//
//  Created by Fernando Romo on 7/17/25.
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?           // Firebase UID
    var firstName: String
    var lastName: String
    var email: String
    var profileImageURL: String?
    var bio: String?
    var level: Int
    var zipCode: String?
    var favoriteRestaurants: [String] // Restaurant IDs
    var followers: [AppUser]
    var following: [AppUser]
    var joinedDate: Date
    var lastLoginAt: Date?
    
    
    static func new(uid: String, firstName: String, lastName: String, email: String, zipCode: String) -> AppUser {
        AppUser(
            id: uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            profileImageURL: nil,
            bio: nil,
            level: 1,
            zipCode: zipCode,
            favoriteRestaurants: [],
            followers: [],
            following: [],
            joinedDate: Date(),
            lastLoginAt: Date()
            )
    }
}

