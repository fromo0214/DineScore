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
    @Published var followerUsers: [AppUser] = []
    @Published var followingUsers: [AppUser] = []
    
    private let db = Firestore.firestore()
    private let repo = AppUserRepository()
    
    func loadSocials(for user: AppUser) async{
        followerUsers = await fetchUsers(ids: user.followers)
        followingUsers = await fetchUsers(ids: user.following)
    }
    
    //retrieves users followers/following ids at the same time
    private func fetchUsers(ids: [String]) async -> [AppUser]{
        //run child tasks on a background executor
        return await withTaskGroup(of: AppUser?.self) { group in
            //add one child task per user id
            for id in ids {
                //this runs for every task per user id, if it fails then return nil and skips it
                group.addTask{ do{
                    return try await self.repo.get(uid: id)
                }catch{
                    print("Failed to fetch \(id): \(error.localizedDescription)")
                    return nil
                }}
            }
            //Collect results as child finishes
            var results: [AppUser] = []
            for await user in group{
                if let user { results.append(user) }
            }
            return results
        }
    }
    
    func updateCurrentUser(firstName: String, lastName: String, zipCode: String) async {
        guard var user = currentUser, let _ = user.id else { return }
        user.firstName = firstName
        user.lastName = lastName
        user.zipCode = zipCode
        do{
            try await repo.upsert(user: user)
            currentUser = user
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
