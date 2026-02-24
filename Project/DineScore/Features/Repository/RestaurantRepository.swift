//
//  RestaurantRepository.swift
//  DineScore
//
//  Created by Fernando Romo on 8/10/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

final class RestaurantRepository{
    
    private let db = Firestore.firestore()
    
    //All restaurants saved in firestore
    private var restaurants: CollectionReference { db.collection("restaurants")}
    
    //fetches restaurant document from firestore
    func fetchRestaurant(id: String) async throws -> RestaurantPublic? {
        let snap = try await restaurants.document(id).getDocument()
        guard snap.exists else { return nil }
        return try snap.data(as: RestaurantPublic.self)
    }
    
    func searchRestaurants(prefix: String, limit: Int = 20) async throws -> [RestaurantPublic] {
        let q = prefix.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        
        async let name = try queryPrefix(field: "name_normalized", q: q, limit: limit)
       
        var combined = try await (name)
        var seen = Set<String>()
        combined = combined.filter { seen.insert($0.id ?? UUID().uuidString).inserted }
        
        return Array(combined.prefix(limit))
    }
    
    func fetchFeaturedRestaurants(limit: Int = 10) async throws -> [RestaurantPublic] {
        let snapshot = try await restaurants
            .order(by: "reviewCount", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: RestaurantPublic.self) }
    }
    
    func fetchTopRatedRestaurants(zipCode: String, limit: Int = 10) async throws -> [RestaurantPublic] {
        let normalizedZip = zipCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedZip.isEmpty else { return [] }
        
        let snapshot = try await restaurants
            .whereField("zipCode", isEqualTo: normalizedZip)
            .limit(to: max(limit * 3, limit))
            .getDocuments()
        
        let decoded = snapshot.documents.compactMap { try? $0.data(as: RestaurantPublic.self) }
        return decoded
            .sorted {
                (($0.avgFoodScore ?? 0) + ($0.avgServiceScore ?? 0)) >
                (($1.avgFoodScore ?? 0) + ($1.avgServiceScore ?? 0))
            }
            .prefix(limit)
            .map { $0 }
    }
    
    private func queryPrefix(field: String, q: String, limit: Int) async throws -> [RestaurantPublic] {
        let snapshot = try await restaurants
            .order(by: field)
            .start(at: [q])
            .end(at: [q + "\u{f8ff}"])
            .limit(to: limit)
            .getDocuments()
        //print("DEBUG:(Restaurants) Query returned \(snapshot.documents.count)")
        let results = snapshot.documents.compactMap{ doc in
            let data = doc.data()
            print("Raw data for restaurant:", data)
            return try? doc.data(as: RestaurantPublic.self)
        }
        //print("DEBUG: Successfully decoded \(results.count) restaurants")
        return results
    }
    
    //prevents duplicated by normalizedKey (name + address)
    func createRestaurantIfNeeded(_ r: Restaurant, completion: @escaping (Result<String, Error>) -> Void) {
        let id = r.normalizedKey  // deterministic ID
        
        //SELECT * FROM restaurants WHERE id = :normalizedKey;
        let ref = restaurants.document(id)
        
        // First read to see if it exists
        ref.getDocument { snap, err in
            if let err = err { return completion(.failure(err)) }
            
            if snap?.exists == true {
                // Already exists: return existing id
                return completion(.success(id))
            } else {
                // Create new restaurant
                var toSave = r
                toSave.ownerId = Auth.auth().currentUser?.uid ?? "unknown"
                do {
                    var data = try Firestore.Encoder().encode(toSave)
                    // Add normalized field used by search
                    if let nameValue = (data["name"] as? String) ?? (Mirror(reflecting: toSave).children.first { $0.label == "name" }?.value as? String) {
                        data["name_normalized"] = self.normalize(nameValue)
                    }
                    ref.setData(data) { error in
                        if let error = error { completion(.failure(error)) }
                        else { completion(.success(id)) }
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }   
    }
    
    // Normalize strings for case/diacritic-insensitive search
    private func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }
}
