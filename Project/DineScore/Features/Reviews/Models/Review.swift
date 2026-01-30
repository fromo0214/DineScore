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
    var likeCount: Int?
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?

    static let detailCompletionMaxScore = 9
    static let detailCompletionThreshold = 5

    var detailCompletionScore: Int {
        var score = 0
        if foodScore != nil { score += 1 }
        if serviceScore != nil { score += 1 }
        if let text = foodText?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty { score += 1 }
        if let text = serviceText?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty { score += 1 }
        if let tags, !tags.isEmpty { score += 1 }
        if let mediaURLS, !mediaURLS.isEmpty { score += 1 }
        if comeBack != nil { score += 1 }
        if priceValue != nil { score += 1 }
        if visitedAt != nil { score += 1 }
        return score
    }

    var detailCompletionRatio: Double {
        guard Review.detailCompletionMaxScore > 0 else { return 0 }
        return Double(detailCompletionScore) / Double(Review.detailCompletionMaxScore)
    }

    var isDetailComplete: Bool {
        detailCompletionScore >= Review.detailCompletionThreshold
    }

    var hasFoodNotes: Bool {
        let text = foodText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return !text.isEmpty
    }

    var hasServiceNotes: Bool {
        let text = serviceText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return !text.isEmpty
    }
}
