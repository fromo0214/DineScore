//
//  Restaurant.swift
//  DineScore
//
//  Created by Fernando Romo on 6/6/25.
//

// Put in Restaurant.swift (or a small Utilities.swift)
extension String {
    /// Trims ends and collapses any internal whitespace to a single space
    func trimAndCollapseSpaces() -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        return parts.joined(separator: " ")
    }
}


import CoreLocation
import FirebaseFirestore
import Foundation

struct Restaurant: Identifiable, Codable{
    @DocumentID var id: String?
    var name: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var cuisine: String
    var priceLevel: Int //1-4
    var photoURL: String?
    var avgFoodScore: Double?
    var avgFoodServiceScore: Double?
    var reviewCount: Int?
    var ownerId: String //owner of person who uploaded restaurant
    var status: String //"pending", "active"
    var normalizedKey: String //for duplicate prevention
    
    var latitude: Double
    var longitude: Double
    
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    
    var coordinate: CLLocationCoordinate2D? {
        .init(latitude: latitude, longitude: longitude)
    }
    
    //nromalized key helper
    // Build a stable, duplicate-resistant key like:
       //  "Test Restaurant | 1711 W"  ->  "test-restaurant-1711-w"
       static func makeNormalizedKey(name: String, address: String) -> String {
           // 1) Trim & collapse internal whitespace
         
           let n = name.trimAndCollapseSpaces()
           let a = address.trimAndCollapseSpaces()

           // 2) Combine, lowercase, remove diacritics
           let combined = "\(n) \(a)".lowercased()
               .folding(options: .diacriticInsensitive, locale: .current)

           // 3) Replace & with "and" (common dupe cause)
           let ampFixed = combined.replacingOccurrences(of: "&", with: "and")

           // 4) Keep only [a-z0-9]+ and collapse to single dashes
           let cleaned = ampFixed.replacingOccurrences(
               of: "[^a-z0-9]+",
               with: "-",
               options: .regularExpression
           )

           // 5) Trim leading/trailing dashes
           return cleaned.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
       }

}
