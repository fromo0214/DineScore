//
//  CreateReviewViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 12/22/25.
//

import Foundation
import SwiftUI
import PhotosUI
import FirebaseAuth

@MainActor
final class CreateReviewViewModel: ObservableObject {
    @Published var restaurant: RestaurantPublic?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // Review form fields (extend as you add UI)
    @Published var foodScore: Double? = nil
    @Published var serviceScore: Double? = nil
    @Published var foodText: String = ""
    @Published var serviceText: String = ""
    
    // Date visited
    @Published var visitDate: Date = Date()
    
    // Photo picking state
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var pickedImages: [UIImage] = []
    @Published var isUploading = false
    @Published var didPost = false
    
    private let maxPhotos = 5
    
    private let restaurantRepo = RestaurantRepository()
    private let userRepo = AppUserRepository()
    private let reviewRepo = ReviewRepository()
    
    let restaurantId: String
    
    init(restaurantId: String) {
        self.restaurantId = restaurantId
    }
    
    init(restaurant: RestaurantPublic) {
        if let id = restaurant.id {
            self.restaurantId = id
        } else if let address = restaurant.address, !address.isEmpty {
            self.restaurantId = address
        } else {
            self.restaurantId = restaurant.name_normalized
        }
        self.restaurant = restaurant
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            if restaurant == nil {
                restaurant = try await restaurantRepo.fetchRestaurant(id: restaurantId)
                if restaurant == nil { errorMessage = "Restaurant not found." }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Decode up to 5 selected PhotosPickerItem values into UIImages
    func loadPickedPhotos() async {
        // Enforce cap at selection time
        if selectedItems.count > maxPhotos {
            selectedItems = Array(selectedItems.prefix(maxPhotos))
        }
        guard !selectedItems.isEmpty else { return }
        
        // Reset and decode fresh each time (or merge if you prefer)
        var images: [UIImage] = []
        for item in selectedItems.prefix(maxPhotos) {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    images.append(img)
                }
            } catch {
                // Skip bad items; collect what we can
                print("Failed to load image from picker: \(error.localizedDescription)")
            }
        }
        // Cap to maxPhotos in case more slipped through
        pickedImages = Array(images.prefix(maxPhotos))
    }
    
    func removeImage(at index: Int) {
        guard pickedImages.indices.contains(index) else { return }
        pickedImages.remove(at: index)
        // Keep selectedItems roughly in sync (best-effort)
        if selectedItems.indices.contains(index) {
            selectedItems.remove(at: index)
        }
    }
    
    var canPost: Bool {
        // You can refine this to require scores/text as you add fields
        return !isUploading && !restaurantId.isEmpty && Auth.auth().currentUser?.uid != nil
    }
    
    // Save review + images to Firestore/Storage via ReviewRepository
    func submitReview() async {
        guard canPost else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be signed in to post a review."
            return
        }
        isUploading = true
        errorMessage = ""
        defer { isUploading = false }
        
        do {
            let _ = try await reviewRepo.createReview(
                restaurantId: restaurantId,
                userId: uid,
                foodScore: foodScore,
                serviceScore: serviceScore,
                foodText: foodText.isEmpty ? nil : foodText,
                serviceText: serviceText.isEmpty ? nil : serviceText,
                visitedAt: visitDate,
                images: pickedImages
            )
            didPost = true
            // Optionally reset form
            pickedImages = []
            selectedItems = []
            foodText = ""
            serviceText = ""
            foodScore = nil
            serviceScore = nil
            visitDate = Date()
        } catch {
            errorMessage = "Failed to post review: \(error.localizedDescription)"
        }
    }
}

