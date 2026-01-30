// Features/Reviews/RestaurantReviewsView.swift
import SwiftUI

struct RestaurantReviewsView: View {
    let restaurantId: String
    @StateObject private var vm: RestaurantReviewsViewModel

    @MainActor init(restaurantId: String, viewModel: RestaurantReviewsViewModel? = nil) {
        self.restaurantId = restaurantId
        if let viewModel {
            _vm = StateObject(wrappedValue: viewModel)
        } else {
            _vm = StateObject(wrappedValue: RestaurantReviewsViewModel())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                ProgressView("Loading reviews…")
            } else if let error = vm.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if vm.reviews.isEmpty {
                Text("No reviews yet.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ReviewsSummaryHeader(
                            averageFoodScore: vm.averageFoodScore,
                            averageServiceScore: vm.averageServiceScore
                        )
                        Divider()
                            .padding(.horizontal, 16)
                        ForEach(vm.reviews) { review in
                            OrganizedReviewCard(review: review)
                                .environmentObject(vm)
                            if review.id != vm.reviews.last?.id {
                                Divider()
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
        }
        .task {
            await vm.loadReviews(for: restaurantId)
        }
    }
}

// MARK: - Organized Review Card
struct OrganizedReviewCard: View {
    let review: Review
    @EnvironmentObject private var vm: RestaurantReviewsViewModel
    
    var body: some View {
        let user = vm.usersById[review.userId]
        let displayName = user?.displayNameShort ?? "Anonymous"
        let avatarURL = user?.profilePicture.flatMap(URL.init(string:))
        let reviewId = review.id ?? ""
        let likeCount = review.likeCount ?? 0
        let isLiked = vm.likedReviewIds.contains(reviewId)
        let isLiking = vm.likingReviewIds.contains(reviewId)
        
        VStack(spacing: 16) {
            // Header section with user info and date
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                if let url = avatarURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                        default:
                            avatarPlaceholder(user: user)
                        }
                    }
                } else {
                    avatarPlaceholder(user: user)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if let badge = vm.badgeLabel(for: review.userId) {
                        Text(badge)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // Date
                if let date = review.createdAt?.dateValue() {
                    Text(formatDate(date))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            
            // Food and Service sections side by side
            HStack(alignment: .top, spacing: 16) {
                // Food section
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Food:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let foodScore = review.foodScore {
                            StarsView(score: foodScore, color: .orange)
                        }
                    }
                    
                    Text(review.foodText ?? "")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Divider between food and service sections
                Divider()
                    .frame(width: 1)
                    .background(Color.gray.opacity(0.5))
                
                // Service section
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Service:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let serviceScore = review.serviceScore {
                            StarsView(score: serviceScore, color: .orange)
                        }
                    }
                    
                    Text(review.serviceText ?? "")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Tags section
            if let tags = review.tags, !tags.isEmpty {
                TagsView(tags: tags)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Photos section
            if let mediaURLs = review.mediaURLS, !mediaURLs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Photos:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(mediaURLs, id: \.self) { urlString in
                                if let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(12)
                                                .clipped()
                                        case .empty:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(12)
                                        case .failure:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(12)
                                                .overlay(
                                                    Image(systemName: "photo")
                                                        .foregroundColor(.gray)
                                                )
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            HStack {
                Spacer()
                Button {
                    Task { await vm.toggleReviewLike(review) }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                        Text("\(likeCount)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(.plain)
                .disabled(reviewId.isEmpty || isLiking)
                .opacity(isLiking ? 0.6 : 1.0)
            }
        }
        .padding(16)
    }
    
    private func avatarPlaceholder(user: UserPublic?) -> some View {
        Circle()
            .fill(Color.blue.opacity(0.2))
            .frame(width: 48, height: 48)
            .overlay(
                Text(initials(from: user))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
            )
    }
    
    private func initials(from user: UserPublic?) -> String {
        guard let u = user else { return "?" }
        let f = u.firstName.first.map(String.init) ?? ""
        let l = u.lastName.first.map(String.init) ?? ""
        return (f + l).uppercased()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Stars View
struct StarsView: View {
    let score: Double
    let color: Color
    let size: CGFloat

    init(score: Double, color: Color, size: CGFloat = 14) {
        self.score = score
        self.color = color
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: starImage(for: index))
                    .foregroundColor(color)
                    .font(.system(size: size))
            }
        }
    }
    
    private func starImage(for index: Int) -> String {
        let position = Double(index) + 1
        if score >= position {
            return "star.fill"
        } else if score >= position - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Tags View
struct TagsView: View {
    let tags: [String]
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(16)
            }
        }
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Reviews Summary Header
struct ReviewsSummaryHeader: View {
    let averageFoodScore: Double
    let averageServiceScore: Double

    var body: some View {
        HStack(spacing: 16) {
            summaryCard(
                title: "Food\nReviews",
                score: averageFoodScore,
                background: Color(red: 0.99, green: 0.46, blue: 0.46)
            )

            summaryCard(
                title: "Service\nReviews",
                score: averageServiceScore,
                background: Color(red: 0.69, green: 0.80, blue: 0.98)
            )
        }
        .padding(16)
    }

    @ViewBuilder
    private func summaryCard(title: String, score: Double, background: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            StarsView(score: score, color: Color(red: 1.0, green: 0.78, blue: 0.29), size: 22)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(background)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        RestaurantReviewsView(restaurantId: "test-restaurant-123-address")
    }
}
