//
//  UserLikesView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/28/25.
//

import SwiftUI

struct UserLikesView: View {
    
    // Dismisses the current view, used for back button
    @Environment(\.dismiss) var dismiss
    
    @State var selectedTab: NavTab = .restaurants
    @State private var showRestaurant = false
    
    @StateObject private var vm: UserProfileViewModel
    
    // Inject the existing view model instance from the parent
    init(vm: UserProfileViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    enum NavTab: String, CaseIterable, Identifiable {
        case restaurants = "Restaurants"
        case reviews = "Reviews"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Picker tab
                    Picker("Nav Tab", selection: $selectedTab) {
                        ForEach(NavTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 5)
                    
                    List {
                        if selectedTab == .restaurants {
                            ForEach(vm.likedRestaurantDetails, id: \.id) { restaurant in
                                let rid = restaurant.id ?? ""
                                // Precompute city/state to keep expressions simple
                                let city = restaurant.city ?? ""
                                let state = restaurant.state ?? ""
                                let hasLocation = !city.isEmpty || !state.isEmpty
                                
                                NavigationLink(destination: RestaurantView(restaurantId: rid)) {
                                    HStack(spacing: 8) {
                                        // Fork & knife icon for restaurants
                                        Image(systemName: "fork.knife.circle.fill")
                                            .foregroundColor(Color.accentColor)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(restaurant.name)
                                                .foregroundColor(Color.accentColor)
                                                .bold()
                                            
                                            if hasLocation {
                                                Text(locationString(city: city, state: state))
                                                    .foregroundColor(Color.accentColor)
                                                    .font(.caption.bold())
                                            }
                                        }
                                    }
                                }
                                .disabled(rid.isEmpty)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task { await vm.unlikeRestaurant(rid) }
                                    } label: {
                                        Label("Unlike", systemImage: "heart.slash")
                                    }
                                }
                            }
                        } else {
                            ForEach(vm.likedReviewDetails) { review in
                                HStack {
                                    Image(systemName: "star.bubble.fill")
                                        .foregroundColor(Color.accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(reviewSummary(review))
                                            .foregroundColor(Color.accentColor)
                                            .lineLimit(1)
                                        if let date = review.createdAt?.dateValue() {
                                            Text(formatDate(date))
                                                .foregroundColor(Color.accentColor)
                                                .font(.caption.bold())
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    let likeCount = review.likeCount ?? 0
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                        Text("\(likeCount)")
                                            .foregroundColor(Color.accentColor)
                                            .font(.caption.bold())
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if let reviewId = review.id {
                                            Task { await vm.unlikeReview(reviewId) }
                                        }
                                    }) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.backgroundColor)
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
            ToolbarItem(placement: .principal) {
                Text("My Likes")
                    .foregroundColor(Color.backgroundColor)
                    .bold()
            }
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
        }
        // Load or refresh likes when this view appears
        .task {
            await vm.getAppUser()
            await vm.refreshLikedRestaurants()
            await vm.refreshLikedRestaurantDetails()
            await vm.refreshLikedReviews()
            await vm.refreshLikedReviewDetails()
        }
    }
    
    // Helper keeps the ViewBuilder simple and avoids optional + concatenation
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
}
