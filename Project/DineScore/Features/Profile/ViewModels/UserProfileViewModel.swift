//
//  UserProfileViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 9/23/25.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class UserProfileViewModel: ObservableObject{
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentUser: AppUser? = nil
    private let db = Firestore.firestore()
    private let repo = AppUserRepository()
    
    func updateCurrentUser(firstName: String, lastName: String, zipCode: String) async{
        guard var user = currentUser else { return }
//        guard let uid = user.id else { return }
        
        user.firstName = firstName
        user.lastName = lastName
        user.zipCode = zipCode
        //user.dob = dob
        
        do{
            try await repo.upsert(user: user)
            self.currentUser = user
        }catch{
            errorMessage = "Failed to update user: \(error.localizedDescription)"
        }
        
        
    }
    
    
    func getAppUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged-in user.")
            currentUser = nil
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let docRef = db.collection("users").document(uid)
            let snapshot = try await docRef.getDocument()
            
            if let user = try? snapshot.data(as: AppUser.self) {
                self.currentUser = user
            }else{
                print("User document not found")
            }
        }catch{
            print("Failed to load user: \(error.localizedDescription)")
        }
    }
}
