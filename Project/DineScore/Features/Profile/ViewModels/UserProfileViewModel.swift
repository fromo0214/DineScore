//
//  UserProfileViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 9/23/25.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SwiftUI

@MainActor
final class UserProfileViewModel: ObservableObject{
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentUser: AppUser? = nil
    @Published var followerUsers: [AppUser] = []
    @Published var followingUsers: [AppUser] = []
    @Published var likedRestaurants: [String] = []
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var pickedImage: UIImage?

    @Published var errorText: String?
    @Published var isSavingPhoto: Bool = false
    @Published var photoSaved: Bool = false

    // New: detailed liked restaurants for UI (names, cover, etc.)
    @Published var likedRestaurantDetails: [RestaurantPublic] = []

    private let db = Firestore.firestore()
    private let repo = AppUserRepository()
    private let uploader = ImageUploader()
    private let restaurantRepo = RestaurantRepository()
    
    // Load liked restaurant IDs for a given uid
    func getLikedRestaurants(uid: String) async throws -> [String] {
        // Use the repository, which already handles Firestore access safely
        return try await repo.getLikedRestaurants(uid: uid)
    }
    
    // Convenience to load the current user's likes and publish them
    func refreshLikedRestaurants() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            likedRestaurants = []
            likedRestaurantDetails = []
            return
        }
        do {
            let ids = try await getLikedRestaurants(uid: uid)
            likedRestaurants = ids
            // Also refresh details for UI
            await refreshLikedRestaurantDetails()
        } catch {
            errorMessage = "Failed to load liked restaurants: \(error.localizedDescription)"
            likedRestaurantDetails = []
        }
    }

    // Fetch RestaurantPublic for each liked restaurant id, concurrently
    func refreshLikedRestaurantDetails() async {
        let ids = likedRestaurants
        guard !ids.isEmpty else {
            likedRestaurantDetails = []
            return
        }
        let results: [RestaurantPublic?] = await withTaskGroup(of: RestaurantPublic?.self) { group in
            for id in ids {
                group.addTask { [restaurantRepo] in
                    do {
                        return try await restaurantRepo.fetchRestaurant(id: id)
                    } catch {
                        // silently skip failures for now
                        return nil
                    }
                }
            }
            var collected: [RestaurantPublic?] = []
            for await r in group {
                collected.append(r)
            }
            return collected
        }
        // Keep order by name, fallback to original order if name missing
        let nonNil = results.compactMap { $0 }
        let sorted = nonNil.sorted { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
        likedRestaurantDetails = sorted
    }
    
    // Add a like for current user and update local state
    func likeRestaurant(_ restaurantId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await repo.likeRestaurant(uid: uid, restaurantId: restaurantId)
            if !likedRestaurants.contains(restaurantId) {
                likedRestaurants.append(restaurantId)
            }
            // Also reflect it into currentUser for consistency
            if var user = currentUser, !user.likedRestaurants.contains(restaurantId) {
                user.likedRestaurants.append(restaurantId)
                currentUser = user
            }
            // Update details list by fetching the new restaurant
            if let detail = try await restaurantRepo.fetchRestaurant(id: restaurantId) {
                if !likedRestaurantDetails.contains(where: { $0.id == detail.id }) {
                    likedRestaurantDetails.append(detail)
                    likedRestaurantDetails.sort {
                        $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                    }
                }
            }
        } catch {
            errorMessage = "Failed to like restaurant: \(error.localizedDescription)"
        }
    }
    
    // Remove a like for current user and update local state
    func unlikeRestaurant(_ restaurantId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await repo.unlikeRestaurant(uid: uid, restaurantId: restaurantId)
            likedRestaurants.removeAll { $0 == restaurantId }
            if var user = currentUser {
                user.likedRestaurants.removeAll { $0 == restaurantId }
                currentUser = user
            }
            // Remove from details as well
            likedRestaurantDetails.removeAll { $0.id == restaurantId }
        } catch {
            errorMessage = "Failed to unlike restaurant: \(error.localizedDescription)"
        }
    }
    
    func loadSocials(for user: AppUser) async{
        followerUsers = await fetchUsers(ids: user.followers)
        followingUsers = await fetchUsers(ids: user.following)
    }
    
    func loadPickedPhoto() async {
        guard let item = selectedPhoto else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data)
            {
                self.pickedImage = img
            }
        } catch {
            self.errorText = "Could not load image."
        }
    }
    
    // Upload avatar, update Firestore, and refresh local user
    func saveProfilePhoto() async {
        guard !isSavingPhoto else { return }
        
        guard let img = pickedImage else {
            errorMessage = "Please pick a photo first."
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Not signed in."
            return
        }
        
        isSavingPhoto = true
        defer { isSavingPhoto = false }
        
        do {
            let url = try await uploader.uploadUserAvatar(img, userId: uid)
            // Update Firestore with both internal and public field names
            try await db.collection("users").document(uid).setData([
                "profileImageURL": url,
                "profilePicture": url, // mirror for UserPublic
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
            
            if var user = currentUser {
                user.profileImageURL = url
                currentUser = user
            }
            photoSaved = true
            pickedImage = nil
            selectedPhoto = nil
            
        } catch {
            errorMessage = "Failed to save photo: \(error.localizedDescription)"
        }
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
            likedRestaurants = []
            likedRestaurantDetails = []
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let docRef = db.collection("users").document(uid)
            let snapshot = try await docRef.getDocument()
            
            if let user = try? snapshot.data(as: AppUser.self) {
                self.currentUser = user
                // Immediately reflect likes into the published array for the UI
                self.likedRestaurants = user.likedRestaurants
                // Build details in background
                Task { await self.refreshLikedRestaurantDetails() }
                // Optionally refresh from server in background to ensure freshness
                Task { await self.refreshLikedRestaurants() }
            }else{
                print("User document not found")
                self.likedRestaurants = []
                self.likedRestaurantDetails = []
            }
        }catch{
            print("Failed to load user: \(error.localizedDescription)")
        }
    }
}

