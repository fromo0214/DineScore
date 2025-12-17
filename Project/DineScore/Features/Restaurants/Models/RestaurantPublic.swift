//
//  RestaurantPublic.swift
//  DineScore
//
//  Created by Fernando Romo on 12/9/25.
//

import Foundation
import FirebaseFirestore

struct RestaurantPublic: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var coverPicture: String?
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var cuisine: String?
    var avgFoodScore: Double?
    var avgServiceScore: Double?
    var reviewCount: Int?
    var priceLevel: Int?
    
    //normalized fields
    var name_normalized: String
    
    init(id: String, name: String, coverPicture: String? = nil, address: String, cuisine: String, avgFoodScore: Double? = nil, avgServiceScore: Double? = nil, reviewCount: Int? = nil, priceLevel: Int, name_normalized: String, state: String, city: String, zipCode: String) {
        self.id = id
        self.name = name
        self.coverPicture = coverPicture
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.cuisine = cuisine
        self.avgFoodScore = avgFoodScore
        self.avgServiceScore = avgServiceScore
        self.reviewCount = reviewCount
        self.priceLevel = priceLevel
        self.name_normalized = name_normalized
    }
}

fileprivate extension String {
    func trimmedLowercased() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
