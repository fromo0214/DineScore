//
//  ListDetailView.swift
//  DineScore
//
//  Created for restaurant list feature
//

import SwiftUI

struct ListDetailView: View {
    let list: RestaurantList
    @ObservedObject var vm: RestaurantListViewModel
    
    @State private var restaurants: [RestaurantPublic] = []
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if let description = list.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                }
                
                if isLoading {
                    ProgressView("Loading restaurants...")
                        .padding()
                    Spacer()
                } else if restaurants.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No restaurants yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Add restaurants from their detail page")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(restaurants) { restaurant in
                            NavigationLink(destination: RestaurantView(restaurantId: restaurant.id!)) {
                                RestaurantRow(restaurant: restaurant)
                            }
                        }
                        .onDelete(perform: removeRestaurant)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadRestaurants()
        }
    }
    
    private func loadRestaurants() async {
        isLoading = true
        restaurants = await vm.fetchRestaurantsForList(list)
        isLoading = false
    }
    
    private func removeRestaurant(at offsets: IndexSet) {
        guard let listId = list.id else { return }
        
        for index in offsets {
            let restaurant = restaurants[index]
            if let restaurantId = restaurant.id {
                Task {
                    do {
                        try await vm.removeRestaurantFromList(listId: listId, restaurantId: restaurantId)
                        await loadRestaurants()
                    } catch {
                        print("Failed to remove restaurant: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
