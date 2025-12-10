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
                            // Header
                            VStack(spacing: 10) {
                                let url = restaurant.coverPicture.flatMap { URL(string: $0) }
                                AsyncImage(url: url, transaction: Transaction(animation: .easeInOut(duration: 0.15))) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable()
                                            .scaledToFill()
                                            .transition(.opacity)
                                    case .empty:
                                        Circle().fill(Color.gray.opacity(0.2))
                                    case .failure:
                                        ZStack {
                                            Circle().fill(Color.gray.opacity(0.2))
                                            Text(initial(from: restaurant))
                                                .font(.title3).bold()
                                                .foregroundColor(.secondary)
                                        }
                                    @unknown default:
                                        Circle().fill(Color.gray.opacity(0.2))
                                    }
                                }
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                
                                Text(restaurant.name)
                                    .font(.title3).bold()
                                Text("@\(restaurant.name)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
//                                FollowButton(targetUserId: user.id)
                            }
                            .padding(.top, 20)
                            
                           
                            
                            // Add sections (lists/reviews/likes) as needed
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage).foregroundColor(.red)
                } else {
                    Text("Restaurant not found!").foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .task { await vm.load() }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func initial(from restaurant: RestaurantPublic) -> String {
        let n = restaurant.name.first.map { String($0) } ?? ""
        return (n).uppercased()
    }
}
