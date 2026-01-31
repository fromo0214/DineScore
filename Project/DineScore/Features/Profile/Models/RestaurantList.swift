//
//  RestaurantList.swift
//  DineScore
//
//  Created for restaurant list feature
//

import Foundation
import FirebaseFirestore

struct RestaurantList: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String?
    var restaurantIds: [String]
    var ownerId: String
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    static func new(name: String, description: String?, ownerId: String) -> RestaurantList {
        RestaurantList(
            id: nil,
            name: name,
            description: description,
            restaurantIds: [],
            ownerId: ownerId,
            createdAt: nil,
            updatedAt: nil
        )
    }
}
