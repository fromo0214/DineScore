//
//  User.swift
//  DineScore
//
//  Created by Fernando Romo on 7/17/25.
//

import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    var id: String               // Firebase UID
    var name: String
    var email: String
    var profileImageURL: String?
    var bio: String?
    var level: Int
    var favoriteRestaurants: [String] // Restaurant IDs
    var followers: [String]
    var following: [String]
    var joinedDate: Date
}

