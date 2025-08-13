//
//  Restaurant.swift
//  DineScore
//
//  Created by Fernando Romo on 6/6/25.
//

import CoreLocation
import FirebaseFirestore
import Foundation

struct Restaurant: Identifiable, Codable{
    @DocumentID var id: String?
    var name: String
    var address: String
    var cuisine: String
    var priceLevel: Int //1-4
    var photoURL: String?
    var avgFoodScore: Double?
    var avgFoodServiceScore: Double?
    var reviewCount: Int?
    var ownerId: String //owner of person who uploaded restaurant
    var status: String //"pending", "active"
    var normalizedKey: String //for duplicate prevention
    
    var latitutde: Double
    var longitude: Double
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    var coordinate: CLLocationCoordinate2D? {
        .init(latitude: latitutde, longitude: longitude)
    }
    
    //nromalized key helper
    func normalizedKey(name: String, address: String) -> String {
        let base = (name + "|" + address)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return base.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

}
