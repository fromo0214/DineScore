//
//  UserPublic.swift
//  DineScore
//
//  Created by Fernando Romo on 10/14/25.
// User Public Profile Model
import Foundation
import FirebaseFirestore

struct UserPublic: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var username: String
    var firstName: String
    var lastName: String
    var profilePicture: String?
    var bio: String?
    
    //Precomputed lowercase keys for search
    var username_normalized: String
    var firstName_normalized: String
    var lastName_normalized: String
    
    var displayNameShort: String{
        let lastInitial = lastName.first.map{ String($0).uppercased()}  ?? ""
        return "\(firstName.capitalized) \(lastInitial))."
    }
    
    init(id: String, username: String, firstName: String, lastName: String, profilePicture: String? = nil, bio: String? = nil, username_normalized: String, firstName_normalized: String, lastName_normalized: String) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.profilePicture = profilePicture
        self.bio = bio
        self.username_normalized = username_normalized
        self.firstName_normalized = firstName_normalized
        self.lastName_normalized = lastName_normalized
    }
}

fileprivate extension String {
    func trimmedLowercased() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
