//
//  RestaurantListRepository.swift
//  DineScore
//
//  Created for restaurant list feature
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class RestaurantListRepository {
    private let db = Firestore.firestore()
    
    private var lists: CollectionReference { db.collection("restaurantLists") }
    
    // Create a new list
    func createList(_ list: RestaurantList) async throws -> String {
        let docRef = try lists.addDocument(from: list)
        return docRef.documentID
    }
    
    // Fetch a single list by ID
    func fetchList(id: String) async throws -> RestaurantList? {
        let snap = try await lists.document(id).getDocument()
        guard snap.exists else { return nil }
        return try snap.data(as: RestaurantList.self)
    }
    
    // Fetch all lists for a user
    func fetchUserLists(ownerId: String) async throws -> [RestaurantList] {
        let snapshot = try await lists
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: RestaurantList.self)
        }
    }
    
    // Update a list
    func updateList(_ list: RestaurantList) async throws {
        guard let id = list.id else { 
            throw NSError(domain: "RestaurantList", code: -1, userInfo: [NSLocalizedDescriptionKey: "List ID is missing"])
        }
        try lists.document(id).setData(from: list, merge: true)
    }
    
    // Delete a list
    func deleteList(id: String) async throws {
        try await lists.document(id).delete()
    }
    
    // Add a restaurant to a list
    func addRestaurantToList(listId: String, restaurantId: String) async throws {
        try await lists.document(listId).updateData([
            "restaurantIds": FieldValue.arrayUnion([restaurantId]),
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    // Remove a restaurant from a list
    func removeRestaurantFromList(listId: String, restaurantId: String) async throws {
        try await lists.document(listId).updateData([
            "restaurantIds": FieldValue.arrayRemove([restaurantId]),
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
}
