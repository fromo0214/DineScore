// Features/Profile/RestaurantView.swift
import SwiftUI
struct RestaurantView: View {
    @StateObject private var vm: RestaurantViewModel
    @State private var showActionsSheet = false
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
            
            Group {
                if vm.isLoading {
                    ProgressView("Loading Restaurant…")
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
                                HStack{
                                    Text(restaurant.name)
                                        .font(.title2).bold()
                                        .foregroundColor(.accent)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if let priceLevel = restaurant.priceLevel {
                                        // Clamp to a reasonable range (e.g., 0...5)
                                        let clamped = max(0, min(priceLevel, 5))
                                        let dollars = String(repeating: "$", count: clamped)
                                        
                                        HStack(spacing: 4) {
                                            Text("Price Level:")
                                                .foregroundColor(.accent)
                                                .bold()
                                            Text(verbatim: dollars)
                                                .font(.title2)
                                                .foregroundColor(.accent)
                                                .accessibilityLabel("Price level \(clamped) out of 5")
                                        }
                                       
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                }
                            
                            HStack(spacing:12){
                                InfoStatBox(
                                    title: "Hours",
                                    value: "Mon: 11:00–9:00\nTues: 11:00–10:00\nWed: 11:00–10:00\nThur: 11:00–10:00\nFri: 11:00–9:00\nSat: Closed\nSun: Closed",
                                    showsChevron: true
                                )
                                
                                InfoStatBox(
                                    title: "Current Wait Time",
                                    value: "10–15 min",
                                    showsChevron: false
                                )
                            }
                            .padding(.horizontal)
                                
                            HStack{
                                if let address = restaurant.address, !address.isEmpty {
                                    Text(address)
                                        .font(.subheadline)
                                        .foregroundColor(.accent)
                                        .frame(maxWidth:.infinity, alignment: .leading)
                                        .bold()
                                        .padding()
                                }
                                
                                InfoStatBox(title: nil, value: "Review, like, add to list...", action:{
                                    showActionsSheet = true
                                })
                                
                            }.padding()
                            
                            //All tags users have used for restaurant
                            HStack{
                                if let cuisine = restaurant.cuisine, !cuisine.isEmpty {
                                    Text(cuisine)
                                        .font(.subheadline)
                                        .foregroundColor(.accent)
                                }
                            }
                            
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
        .sheet(isPresented: $showActionsSheet) {
            ActionOptionsSheet(
                onLike: {
                    // TODO: Implement "Like" action
                    showActionsSheet = false
                },
                onReview: {
                    // TODO: Navigate to review flow
                    showActionsSheet = false
                },
                onAddToList: {
                    // TODO: Present list picker
                    showActionsSheet = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .background(Color.backgroundColor)
        }
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

private struct InfoStatBox: View {
    let title: String?
    let value: String? // optional so we can omit the value section entirely
    var showsChevron: Bool = false
    var action: (() -> Void)? = nil
    
    @State private var isExpanded = false
    
    var body: some View {
        // Compute presence of value
        let hasValue: Bool = {
            guard let v = value else { return false }
            return !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }()
        
        let hasTitle: Bool = {
            guard let t = title else { return false }
            return !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }()
        
        // Core content
        let content = VStack(spacing: hasValue ? 8 : 0) {
            // Header with title and optional chevron that controls expansion
            HStack {
                if hasTitle, let t = title{
                    Text(t)
                        .font(.headline)
                        .foregroundColor(.backgroundColor)
                        .bold()
                }
                
                Spacer()
                
                if showsChevron {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.backgroundColor.opacity(0.9))
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                            .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Value section (only when present)
            if hasValue, let v = value {
                Text(v)
                    .font(.subheadline)
                    .foregroundColor(.backgroundColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(isExpanded ? nil : 1) // collapsed shows one line
                    .accessibilityLabel("\(title): \(v)")
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.textColor)
        )
        .contentShape(Rectangle())
        
        // Wrap in a button when an action is provided so the whole box is tappable
        if let action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
}

// Bottom sheet with actions
private struct ActionOptionsSheet: View {
    var onLike: () -> Void
    var onReview: () -> Void
    var onAddToList: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .accessibilityHidden(true)
            
            Text("Actions")
                .font(.title3).bold()
                .foregroundColor(.accentColor)
                .padding(.top, 4)
            
            VStack(spacing: 12) {
                Button {
                    onLike()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("Like")
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColor))
                }
                
                Button {
                    onReview()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Write a Review")
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColor))
                }
                
                Button {
                    onAddToList()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "text.badge.plus")
                        Text("Add to List")
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColor))
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color.backgroundColor.ignoresSafeArea())
    }
}


#Preview {
    RestaurantView(restaurantId: "test-restaurant-123-address")
}
