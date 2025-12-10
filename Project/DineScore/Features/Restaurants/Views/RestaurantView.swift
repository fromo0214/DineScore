// Features/Profile/RestaurantView.swift
import SwiftUI

struct RestaurantView: View {
    @StateObject private var vm: RestaurantViewModel
    
    init(restaurantId: String) {
        _vm = StateObject(wrappedValue: RestaurantViewModel(restaurantId: restaurantId))
    }
    
    // Build a dynamic title using normalized names, with a safe fallback
    private var navTitle: String {
        if let restaurant = vm.restaurant {
            let combined = restaurant.name
            return combined.isEmpty ? "Restaurant" : combined
        } else {
            return "Restaurant"
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            
            SwiftUI.Group {
                if vm.isLoading {
                    SwiftUI.ProgressView("Loading Restaurant…")
                } else if let restaurant = vm.restaurant {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Cover header
                            coverHeader(restaurant)
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .background(Color.gray.opacity(0.15))
                            
                            // Basic info
                            VStack(spacing: 6) {
                                Text(restaurant.name)
                                    .font(.title2).bold()
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.accent)
                                
                                if let address = restaurant.address, !address.isEmpty {
                                    Text(address)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                
                                if let cuisine = restaurant.cuisine, !cuisine.isEmpty {
                                    Text(cuisine)
                                        .font(.subheadline)
                                        .foregroundColor(.accent)
                                }
                                
                                if let priceLevel = restaurant.priceLevel {
                                    // Clamp to a reasonable range (e.g., 0...5)
                                    let clamped = max(0, min(priceLevel, 5))
                                    let dollars = String(repeating: "$", count: clamped)
                                    
                                    HStack(spacing: 4) {
                                        Text("Price Level:")
                                        // Use verbatim to ensure the dollar signs render literally
                                        Text(verbatim: dollars)
                                            .font(.subheadline)
                                            .foregroundColor(.accent)
                                            .accessibilityLabel("Price level \(clamped) out of 5")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.accent)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            
                            // Add sections (lists/reviews/likes) as needed
                            // ...
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage).foregroundColor(.red)
                } else {
                    Text("Restaurant not found!").foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 0) // let cover go edge-to-edge
        }
        .task { await vm.load() }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Renders a wide, aspect-filled cover image with graceful fallbacks
    @ViewBuilder
    private func coverHeader(_ restaurant: RestaurantPublic) -> some View {
        let url = restaurant.coverPicture.flatMap { URL(string: $0) }
        
        AsyncImage(
            url: url,
            transaction: Transaction(animation: .easeInOut(duration: 0.2))
        ) { phase in
            switch phase {
            case .success(let img):
                img
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            case .empty:
                placeholder(for: restaurant)
            case .failure:
                placeholder(for: restaurant)
            @unknown default:
                placeholder(for: restaurant)
            }
        }
    }
    
    private func placeholder(for restaurant: RestaurantPublic) -> some View {
        ZStack {
            Color.gray.opacity(0.15)
            Text(initial(from: restaurant))
                .font(.largeTitle).bold()
                .foregroundColor(.secondary)
        }
    }
    
    private func initial(from restaurant: RestaurantPublic) -> String {
        let n = restaurant.name.first.map { String($0) } ?? ""
        return n.uppercased()
    }
}
