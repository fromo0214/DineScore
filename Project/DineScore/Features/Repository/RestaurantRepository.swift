//
//  RestaurantRepository.swift
//  DineScore
//
//  Created by Fernando Romo on 8/10/25.
//

import FirebaseAuth
import FirebaseFirestore

final class RestaurantRepository{
    private let db = Firestore.firestore()
    private var col: CollectionReference { db.collection("restaurants")}
    
    
    //Java spring boot translation
    // Equivalent behavior with SQL
//    if (!restaurantRepository.existsById(normalizedKey)) {
//        restaurantRepository.save(new Restaurant(normalizedKey, name, address, ...));
//    }
    
    //prevents duplicated by normalizedKey (name + address)
    func createRestaurantIfNeeded(_ r: Restaurant, completion: @escaping (Result<String, Error>) -> Void) {
        let id = r.normalizedKey  // deterministic ID
        
        //SELECT * FROM restaurants WHERE id = :normalizedKey;
        let ref = col.document(id)
        
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
                    let data = try Firestore.Encoder().encode(toSave)
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
}
