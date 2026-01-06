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
    
    // Review form fields
    @Published var foodScore: Double? = nil
    @Published var serviceScore: Double? = nil
    @Published var foodText: String = ""
    @Published var serviceText: String = ""
    
    // Would you come back / Price vs value
    @Published var comeBack: ComeBackOption = .maybe
    @Published var priceValue: PriceValueOption = .okay
    
    // Tags
    @Published var selectedTags: [String] = []
    @Published var newTagText: String = ""
    // You can load these from Firestore later; start with a static list
    @Published var suggestedTags: [String] = [
        "Friendly staff", "Fast service", "Slow service", "Great value", "Overpriced",
        "Cozy", "Loud", "Romantic", "Family-friendly", "Great cocktails",
        "Fresh ingredients", "Large portions", "Small portions", "Clean", "Crowded"
    ]
    let maxTags = 10
    let maxTagLength = 24
    
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
        if selectedItems.count > maxPhotos {
            selectedItems = Array(selectedItems.prefix(maxPhotos))
        }
        guard !selectedItems.isEmpty else { return }
        
        var images: [UIImage] = []
        for item in selectedItems.prefix(maxPhotos) {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    images.append(img)
                }
            } catch {
                print("Failed to load image from picker: \(error.localizedDescription)")
            }
        }
        pickedImages = Array(images.prefix(maxPhotos))
    }
    
    func removeImage(at index: Int) {
        guard pickedImages.indices.contains(index) else { return }
        pickedImages.remove(at: index)
        if selectedItems.indices.contains(index) {
            selectedItems.remove(at: index)
        }
    }
    
    // Tag helpers
    func toggleSuggestedTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0.caseInsensitiveCompare(tag) == .orderedSame }
        } else {
            addTag(tag)
        }
    }
    
    func addNewTag() {
        let trimmed = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        addTag(trimmed)
        newTagText = ""
    }
    
    private func addTag(_ raw: String) {
        guard selectedTags.count < maxTags else { return }
        var tag = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if tag.count > maxTagLength {
            tag = String(tag.prefix(maxTagLength))
        }
        // Normalize spaces
        tag = tag.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        guard !tag.isEmpty else { return }
        // Avoid duplicates (case-insensitive)
        guard !selectedTags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) else { return }
        selectedTags.append(tag)
    }
    
    func removeTag(_ tag: String) {
        selectedTags.removeAll { $0.caseInsensitiveCompare(tag) == .orderedSame }
    }
    
    var canPost: Bool {
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
                comeBack: comeBack,
                priceValue: priceValue,
                tags: selectedTags.isEmpty ? nil : selectedTags,
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
            comeBack = .maybe
            priceValue = .okay
            selectedTags = []
            newTagText = ""
        } catch {
            errorMessage = "Failed to post review: \(error.localizedDescription)"
        }
    }
}

