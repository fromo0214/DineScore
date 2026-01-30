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
    @Published var likedReviews: [String] = []
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var pickedImage: UIImage?

    @Published var errorText: String?
    @Published var isSavingPhoto: Bool = false
    @Published var photoSaved: Bool = false

    // New: detailed liked restaurants for UI (names, cover, etc.)
    @Published var likedRestaurantDetails: [RestaurantPublic] = []
    
    // New: recent activities
    @Published var recentActivities: [UserActivity] = []
    @Published var likedReviewDetails: [Review] = []
    @Published var myReviews: [Review] = []
    @Published var reviewerLevel: ReviewerLevel?

    private let db = Firestore.firestore()
    private let repo = AppUserRepository()
    private let uploader = ImageUploader()
    private let restaurantRepo = RestaurantRepository()
    private let activityRepo = ActivityRepository()

    private let reviewRepo = ReviewRepository()
    
    // Load liked restaurant IDs for a given uid
    func getLikedRestaurants(uid: String) async throws -> [String] {
        // Use the repository, which already handles Firestore access safely
        return try await repo.getLikedRestaurants(uid: uid)
    }
    
    // Convenience to load the current user's likes and publish them
    func refreshLikedRestaurants() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            likedRestaurants = []
            likedReviews = []
            likedRestaurantDetails = []
            likedReviewDetails = []
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

    func refreshLikedReviews() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            likedReviews = []
            likedReviewDetails = []
            return
        }
        do {
            let ids = try await repo.getLikedReviews(uid: uid)
            likedReviews = ids
            await refreshLikedReviewDetails()
        } catch {
            errorMessage = "Failed to load liked reviews: \(error.localizedDescription)"
            likedReviewDetails = []
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

    func refreshLikedReviewDetails() async {
        let ids = likedReviews
        guard !ids.isEmpty else {
            likedReviewDetails = []
            return
        }
        var details: [Review] = []
        details.reserveCapacity(ids.count)
        for id in ids {
            do {
                if let review = try await reviewRepo.fetchReview(id: id) {
                    details.append(review)
                }
            } catch {
                errorMessage = "Failed to load liked reviews: \(error.localizedDescription)"
            }
        }
        likedReviewDetails = details
    }

    func refreshMyReviews() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            myReviews = []
            reviewerLevel = nil
            return
        }
        do {
            let reviews = try await reviewRepo.fetchReviewsByUser(uid, limit: 100)
            myReviews = reviews
            reviewerLevel = ReviewerLevelCalculator.level(from: reviews)
        } catch {
            errorMessage = "Failed to load reviews: \(error.localizedDescription)"
            myReviews = []
            reviewerLevel = nil
        }
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

    func likeReview(_ reviewId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await repo.likeReview(uid: uid, reviewId: reviewId)
            if !likedReviews.contains(reviewId) {
                likedReviews.append(reviewId)
            }
            if var user = currentUser {
                let existing = user.likedReviews
                if !existing.contains(reviewId) {
                    user.likedReviews = existing + [reviewId]
                    currentUser = user
                }
            }
            await refreshLikedReviewDetails()
        } catch {
            errorMessage = "Failed to like review: \(error.localizedDescription)"
        }
    }

    func unlikeReview(_ reviewId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await repo.unlikeReview(uid: uid, reviewId: reviewId)
            likedReviews.removeAll { $0 == reviewId }
            if var user = currentUser {
                user.likedReviews.removeAll { $0 == reviewId }
                currentUser = user
            }
            likedReviewDetails.removeAll { $0.id == reviewId }
        } catch {
            errorMessage = "Failed to unlike review: \(error.localizedDescription)"
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
            likedReviews = []
            likedRestaurantDetails = []
            recentActivities = []

            likedReviewDetails = []
            myReviews = []
            reviewerLevel = nil
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            if let user = try await repo.get(uid: uid) {
                currentUser = user
                // Immediately reflect likes into the published array for the UI
                likedRestaurants = user.likedRestaurants
                likedReviews = user.likedReviews
                // Build details in background
                Task { await self.refreshLikedRestaurantDetails() }
                // Optionally refresh from server in background to ensure freshness
                Task { await self.refreshLikedRestaurants() }
                // Fetch recent activities
                Task { await self.fetchRecentActivities(userId: uid) }
                Task { await self.refreshLikedReviewDetails() }
                Task { await self.refreshMyReviews() }
            } else {
                errorMessage = "User document not found."
                likedRestaurants = []
                likedReviews = []
                likedRestaurantDetails = []
                recentActivities = []
                likedReviewDetails = []
                myReviews = []
                reviewerLevel = nil
            }
        } catch {
            errorMessage = "Failed to load user: \(error.localizedDescription)"
        }
    }
    
    // Fetch recent activities for a user
    func fetchRecentActivities(userId: String) async {
        do {
            let activities = try await activityRepo.fetchRecentActivities(userId: userId, limit: 10)
            self.recentActivities = activities
        } catch {
            print("Failed to fetch activities: \(error.localizedDescription)")
            self.recentActivities = []
        }
    }
}
