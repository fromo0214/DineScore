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
    
    // Placeholder until you add real liked reviews support
    @State private var reviews: [String] = ["Review 1", "Review 2", "Review 3"]
    
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
                            ForEach(reviews, id: \.self) { item in
                                HStack {
                                    // Photo icon for reviews for now (replace with AsyncImage when you have imageURL)
                                    Image(systemName: "person.fill")
                                        .foregroundColor(Color.accentColor)
                                    
                                    Text(item)
                                        .foregroundColor(Color.accentColor)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // Remove liked review when you implement reviews
                                        reviews.removeAll { $0 == item }
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
}

