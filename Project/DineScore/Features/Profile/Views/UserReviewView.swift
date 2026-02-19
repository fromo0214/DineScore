//
//  UserReviewView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/28/25.
//

import SwiftUI

struct UserReviewView: View {
    //dismisses the current view, used for back button
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: UserProfileViewModel
    @State private var restaurantDetails: [String: RestaurantPublic] = [:]
    @State private var isLoadingReviews = false
    
    private let restaurantRepo = RestaurantRepository()
    
    init(vm: UserProfileViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                if isLoadingReviews && vm.myReviews.isEmpty {
                    ProgressView("Loading reviews...")
                        .padding()
                } else if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if vm.myReviews.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "star.bubble")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No reviews yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Write a review to see it here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(vm.myReviews) { review in
                            let restaurant = restaurantDetails[review.restaurantId]
                            NavigationLink(destination: RestaurantReviewsView(restaurantId: review.restaurantId, highlightReviewId: review.id)) {
                                reviewRow(review: review, restaurant: restaurant)
                            }
                        }
                        .listRowBackground(Color.backgroundColor)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.textColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            //custom back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.backgroundColor)
                        Text("Profile")
                            .foregroundColor(Color.backgroundColor)
                            .bold()
                    }
                }
            }
            
            //navigation title
            ToolbarItem(placement: .principal) {
                Text("My Reviews")
                    .foregroundColor(Color.backgroundColor)
                    .bold()
            }
            
            //filtering button
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    //sorting func
                }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color.backgroundColor)
                    }
                }
            }
        }
        .task {
            isLoadingReviews = true
            await vm.getAppUser()
            await vm.refreshMyReviews()
            await loadRestaurantDetails(for: vm.myReviews)
            isLoadingReviews = false
        }
        .onChange(of: vm.myReviews) { reviews in
            Task {
                await loadRestaurantDetails(for: reviews)
            }
        }
    }
    
    private func reviewRow(review: Review, restaurant: RestaurantPublic?) -> some View {
        let restaurantName = restaurant?.name ?? "Restaurant"
        let city = restaurant?.city ?? ""
        let state = restaurant?.state ?? ""
        let location = locationString(city: city, state: state)
        
        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "fork.knife.circle.fill")
                    .foregroundColor(Color.accentColor)
                Text(restaurantName)
                    .foregroundColor(Color.accentColor)
                    .font(.headline)
                Spacer()
            }
            
            if !location.isEmpty {
                Text(location)
                    .foregroundColor(.secondary)
                    .font(.caption.bold())
            }
            
            Text(reviewSummary(review))
                .foregroundColor(Color.textColor)
                .font(.subheadline)
                .lineLimit(2)
            
            if let date = review.createdAt?.dateValue() {
                Text(formatDate(date))
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 6)
    }
    
    private func locationString(city: String, state: String) -> String {
        switch (city.isEmpty, state.isEmpty) {
        case (false, false): return "\(city), \(state)"
        case (false, true):  return city
        case (true, false):  return state
        default:             return ""
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func reviewSummary(_ review: Review) -> String {
        if let text = review.foodText?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            return text
        }
        if let text = review.serviceText?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            return text
        }
        return "Review"
    }
    
    @MainActor
    private func loadRestaurantDetails(for reviews: [Review]) async {
        let ids = Set(reviews.map { $0.restaurantId })
        let missing = ids.subtracting(restaurantDetails.keys).filter { !$0.isEmpty }
        guard !missing.isEmpty else { return }
        let results: [String: RestaurantPublic] = await withTaskGroup(of: (String, RestaurantPublic?).self) { group in
            for id in missing {
                group.addTask { [restaurantRepo] in
                    do {
                        return (id, try await restaurantRepo.fetchRestaurant(id: id))
                    } catch {
                        return (id, nil)
                    }
                }
            }
            var collected: [String: RestaurantPublic] = [:]
            for await (id, restaurant) in group {
                if let restaurant {
                    collected[id] = restaurant
                }
            }
            return collected
        }
        restaurantDetails.merge(results) { _, new in new }
    }
}

#Preview {
    UserReviewView(vm: UserProfileViewModel())
}
