//
//  Review.swift
//  DineScore
//
//  Created by Fernando Romo on 7/17/25.
//
import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable{
    @DocumentID var id: String?
    var restaurantId: String
    var userId: String
    var foodScore: Double?
    var serviceScore: Double?
    var foodText: String?
    var serviceText: String?
    var mediaURLS: [String]?
    
    // New: date user visited the restaurant
    var visitedAt: Date?
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
}

