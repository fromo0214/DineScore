//
//  Review.swift
//  DineScore
//
//  Created by Fernando Romo on 7/17/25.
//
import Foundation
import FirebaseFirestore

enum ComeBackOption: String, Codable, CaseIterable, Identifiable {
    case yes, maybe, no
    var id: Self { self }
    var title: String {
        switch self {
        case .yes: return "Yes"
        case .maybe: return "Maybe"
        case .no: return "No"
        }
    }
}

enum PriceValueOption: String, Codable, CaseIterable, Identifiable {
    case great, okay, notWorthIt
    var id: Self { self }
    var title: String {
        switch self {
        case .great: return "Great"
        case .okay: return "Okay"
        case .notWorthIt: return "Not worth it"
        }
    }
}

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
    
    // New: additional fields
    var comeBack: ComeBackOption?
    var priceValue: PriceValueOption?
    
    // New: tags users add to reviews
    var tags: [String]?
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
}

