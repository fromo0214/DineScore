// Features/Profile/RestaurantView.swift
import SwiftUI
import FirebaseFirestore
struct RestaurantView: View {
    @StateObject private var vm: RestaurantViewModel
    @State private var showActionsSheet = false
    @State private var showReviewSheet = false
    @State private var showAddToListSheet = false
    
    
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
                                
                                
                                HStack() {
                                    Text(restaurant.name)
                                        .font(.title2).bold()
                                        .foregroundColor(.accentColor)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .layoutPriority(1)
                                    
                                    if let cuisine = restaurant.cuisine, !cuisine.isEmpty {
                                        Text(cuisine)
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.backgroundColor)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background(
                                                Capsule().fill(Color.accentColor.opacity(0.85))
                                            )
                                            .fixedSize(horizontal: true, vertical: true)
                                            .accessibilityLabel("Cuisine: \(cuisine)")
                                    }
                                    
                                    Spacer()
                                    
                                    
                                    
                                    if let priceLevel = restaurant.priceLevel {
                                        // Clamp to a reasonable range (e.g., 0...5)
                                        let clamped = max(0, min(priceLevel, 5))
                                        let dollars = String(repeating: "$", count: clamped)
                                        
                                        HStack(spacing: 4) {
                                            Text("Price Level:")
                                                .foregroundColor(.accentColor)
                                                .bold()
                                            Text(verbatim: dollars)
                                                .font(.title2)
                                                .foregroundColor(.accentColor)
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
                            
                            if !vm.topTags.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    RestaurantFlowLayout(spacing: 8, rowSpacing: 8) {
                                        ForEach(vm.topTags, id: \.self) { tag in
                                            SmallTagChip(text: tag)
                                                .fixedSize()
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            HStack(alignment: .top, spacing: 12){
                                if let address = restaurant.address, let city = restaurant.city, let state = restaurant.state, let zipCode = restaurant.zipCode, !address.isEmpty {
                                    AddressCard(address: address, city: city, state: state, zipCode: zipCode, name: restaurant.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                
                            }
                            .padding(.horizontal)
                            
                            // Action row: Like / Review / Add to List / Share styled like InfoStatBox
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    ActionStatButton(
                                        title: vm.isLiked ? "Unlike" : "Like",
                                        systemImage: vm.isLiked ? "heart.fill" : "heart"
                                    ) {
                                        Task { await vm.toggleLike() }
                                    }
                                    .disabled(vm.isLiking)
                                    .opacity(vm.isLiking ? 0.6 : 1.0)
                                    
                                    ActionStatButton(
                                        title: "Review",
                                        systemImage: "square.and.pencil"
                                    ) {
                                        // Present CreateReviewView with the already-loaded restaurant
                                        showReviewSheet = true
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    ActionStatButton(
                                        title: "Add to List",
                                        systemImage: "text.badge.plus"
                                    ) {
                                        showAddToListSheet = true
                                    }
                                    
                                    // Share styled to match
                                    ActionShareBox(
                                        title: "Share",
                                        systemImage: "square.and.arrow.up",
                                        shareText: {
                                            if let address = restaurant.address,
                                               let city = restaurant.city,
                                               let state = restaurant.state,
                                               let zip = restaurant.zipCode {
                                                return "\(restaurant.name)\n\(address), \(city), \(state) \(zip)"
                                            } else {
                                                return restaurant.name
                                            }
                                        }()
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            let foodAvg = vm.avgFoodScore ?? restaurant.avgFoodScore
                            let serviceAvg = vm.avgServiceScore ?? restaurant.avgServiceScore

                            if foodAvg != nil || serviceAvg != nil {
                                HStack(spacing: 8) {
                                    if let food = foodAvg {
                                        Text("Food:")
                                            .foregroundColor(.textColor)
                                        Text(String(format: "%.1f" + "⭐️", food))
                                            .font(.callout)
                                            .foregroundColor(.accentColor)
                                    }
                                    if foodAvg != nil && serviceAvg != nil {
                                        Text("·").foregroundColor(.accentColor).bold()
                                    }
                                    if let service = serviceAvg {
                                        Text("Service:")
                                            .foregroundColor(.textColor)
                                        Text(String(format: "%.1f" + "⭐️", service))
                                            .font(.callout)
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Recent Reviews section (shows up to 2 most recent)
                            if !vm.recentTwoReviews.isEmpty {
                                RecentReviewsSection(reviews: vm.recentTwoReviews, restaurantId: vm.restaurantId)
                                    .padding(.horizontal)
                            } else if !vm.reviews.isEmpty {
                                RecentReviewsSection(reviews: Array(vm.reviews.prefix(2)), restaurantId: vm.restaurantId)
                                    .padding(.horizontal)
                            }
                            
                            
                            // Add sections (lists/reviews/likes) as needed
                            // ...
                            
                        }
                        .frame(maxWidth: .infinity)
                        .environmentObject(vm)
                    }
                    // Present CreateReviewView using RestaurantPublic (no extra fetch)
                    .sheet(isPresented: $showReviewSheet) {
                        CreateReviewView(restaurant: restaurant)
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
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
            if let restaurant = vm.restaurant {
                ActionOptionsSheet(
                    restaurant: restaurant,
                    onLike: {
                        showActionsSheet = false
                    },
                    onReview: {
                        showActionsSheet = false
                        showReviewSheet = true
                    },
                    onAddToList: {
                        // Present list picker
                        showActionsSheet = false
                        showAddToListSheet = true
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .background(Color.backgroundColor)
            } else {
                // Fallback in case restaurant becomes nil
                EmptyView()
            }
        }
        .sheet(isPresented: $showAddToListSheet) {
            if let restaurant = vm.restaurant {
                AddToListView(restaurantId: restaurant.id ?? "", restaurantName: restaurant.name)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
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
                    .accessibilityLabel(
                        Text(
                            verbatim: {
                                if let t = title, !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    return "\(t): \(v)"
                                } else {
                                    return v
                                }
                            }()
                        )
                    )
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

// Address card for nicer presentation + actions
private struct AddressCard: View {
    let address: String
    let city: String
    let state: String
    let zipCode: String
    let name: String
    
    @Environment(\.openURL) private var openURL
    
    private var mapsURL: URL? {
        // Prefer a name + address query to improve accuracy
        let query = "\(name) \(address)"
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "http://maps.apple.com/?q=\(encoded)")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Address", systemImage: "mappin.and.ellipse")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.accentColor)
            
            Text(address + ", \(city), \(state) \(zipCode)")
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            
            HStack(spacing: 8) {
                if let url = mapsURL {
                    Button {
                        openURL(url)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            Text("Directions")
                                .lineLimit(1)
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .layoutPriority(1)
                        .font(.footnote.bold())
                        .foregroundColor(.backgroundColor)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule().fill(Color.accentColor)
                        )
                    }
                }
                
                ShareLink(item: address) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .lineLimit(1)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
                    .font(.footnote.bold())
                    .foregroundColor(.accentColor)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule().stroke(Color.accentColor, lineWidth: 1)
                    )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.textColor.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.textColor.opacity(0.08), lineWidth: 1)
        )
    }
}

// Bottom sheet with actions
private struct ActionOptionsSheet: View {
    let restaurant: RestaurantPublic
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
            
            Text(restaurant.name)
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

// MARK: - Styled Action Buttons (matching InfoStatBox look)
private struct ActionStatButton: View {
    let title: String
    let systemImage: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(.backgroundColor)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.textColor)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ActionShareBox: View {
    let title: String
    let systemImage: String
    let shareText: String
    
    var body: some View {
        ShareLink(item: shareText) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(.backgroundColor)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.textColor)
            )
        }
    }
}

// MARK: - Small tag chip (display only)
private struct SmallTagChip: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.footnote.bold())
            .foregroundColor(.accentColor)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule().fill(Color.textColor.opacity(0.12))
            )
            .overlay(
                Capsule().stroke(Color.accentColor.opacity(0.6), lineWidth: 1)
            )
    }
}

// MARK: - Simple FlowLayout for wrapping chips
private struct RestaurantFlowLayout: Layout {
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 8
    
    init(spacing: CGFloat = 8, rowSpacing: CGFloat = 8) {
        self.spacing = spacing
        self.rowSpacing = rowSpacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                // wrap
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        if subviews.isEmpty == false {
            y += rowHeight
        }
        return CGSize(width: maxWidth, height: y)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                // wrap
                x = bounds.minX
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            sub.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Recent Reviews Section (horizontal & tappable)
private struct RecentReviewsSection: View {
    let reviews: [Review]
    let restaurantId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Reviews")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.accentColor)
                    .accessibilityHidden(true)
            }

            NavigationLink {
                RestaurantReviewsView(restaurantId: restaurantId)
            } label: {
                HStack(spacing: 12) {
                    ForEach(reviews.prefix(2)) { review in
                        ReviewMiniCard(review: review)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.textColor.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Compact review card for the horizontal layout
private struct ReviewMiniCard: View {
    @EnvironmentObject private var vm: RestaurantViewModel
    let review: Review

    var body: some View {
        let date = review.createdAt?.dateValue()
        let food = review.foodScore
        let service = review.serviceScore
        let firstText = ([review.foodText, review.serviceText]
            .compactMap { $0 }
            .first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ?? ""
        let avg: Double? = {
            let scores = [food, service].compactMap { $0 }
            guard !scores.isEmpty else { return nil }
            return scores.reduce(0, +) / Double(scores.count)
        }()

        // Lookup user if we have it
        let user = vm.usersById[review.userId]
        let displayName = user?.displayNameShort ?? "Anonymous"
        let avatarURL = user?.profilePicture.flatMap(URL.init(string:))

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                // Avatar
                if let url = avatarURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .empty:
                            Circle().fill(Color.gray.opacity(0.25))
                        case .failure:
                            Circle().fill(Color.gray.opacity(0.25))
                        @unknown default:
                            Circle().fill(Color.gray.opacity(0.25))
                        }
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.25))
                        .overlay(Text(initials(from: user)).font(.caption2.bold()).foregroundColor(.secondary))
                        .frame(width: 28, height: 28)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.caption.bold())
                        .foregroundColor(.accentColor)
                    if let date {
                        Text(relativeDateString(from: date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if let avg {
                    let clamped = max(0, min(avg, 5))
                    let stars = String(repeating: "⭐️", count: Int(clamped.rounded()))
                    Text(stars)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }

            if !firstText.isEmpty {
                Text(firstText)
                    .font(.footnote)
                    .foregroundColor(.textColor)
                    .lineLimit(3)
            }
        }
    }

    private func initials(from user: UserPublic?) -> String {
        guard let u = user else { return "" }
        let f = u.firstName.first.map(String.init) ?? ""
        let l = u.lastName.first.map(String.init) ?? ""
        return (f + l).uppercased()
    }
    
    private func relativeDateString(from date: Date) -> String {
        let now = Date()
        let seconds = max(0, now.timeIntervalSince(date))
        let minute = 60.0
        let hour = 60.0 * minute
        let day = 24.0 * hour
        if seconds < minute {
            return "Just now"
        } else if seconds < hour {
            let m = Int(seconds / minute)
            return "\(m)m ago"
        } else if seconds < day {
            let h = Int(seconds / hour)
            return "\(h)h ago"
        } else if seconds < 7 * day {
            let d = Int(seconds / day)
            return "\(d)d ago"
        } else {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            return df.string(from: date)
        }
    }
}

#Preview {
    RestaurantView(restaurantId: "test-restaurant-123-address")
}

