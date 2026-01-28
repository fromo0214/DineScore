import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class RestaurantViewModel: ObservableObject {
    @Published var restaurant: RestaurantPublic?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var topTags: [String] = []
    @Published var isLiked = false
    @Published var isLiking = false
    @Published var avgFoodScore: Double?
    @Published var avgServiceScore: Double?
    @Published var reviews: [Review] = []
    @Published var usersById: [String: UserPublic] = [:]

    var recentTwoReviews: [Review] {
        let sorted = reviews.sorted { lhs, rhs in
            let l = lhs.createdAt?.dateValue() ?? Date.distantPast
            let r = rhs.createdAt?.dateValue() ?? Date.distantPast
            return l > r
        }
        return Array(sorted.prefix(2))
    }

    let restaurantId: String

    private let restaurantRepo = RestaurantRepository()
    private let reviewRepo = ReviewRepository()
    private let userRepo = AppUserRepository()

    init(restaurantId: String) {
        self.restaurantId = restaurantId
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        errorMessage = ""
        do {
            restaurant = try await restaurantRepo.fetchRestaurant(id: restaurantId)
            await refreshLikeState()
            await loadTopTags(limit: 3, minCount: 4)
        } catch {
            errorMessage = "Failed to load restaurant: \(error.localizedDescription)"
        }
    }

    func refreshLikeState() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLiked = false
            return
        }
        do {
            let liked = try await userRepo.getLikedRestaurants(uid: uid)
            isLiked = liked.contains(restaurantId)
        } catch {
            // Non-fatal; default to not liked
            isLiked = false
        }
    }

    func toggleLike() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !isLiking else { return }
        isLiking = true
        defer { isLiking = false }
        do {
            if isLiked {
                try await userRepo.unlikeRestaurant(uid: uid, restaurantId: restaurantId)
                isLiked = false
            } else {
                try await userRepo.likeRestaurant(uid: uid, restaurantId: restaurantId)
                isLiked = true
            }
        } catch {
            errorMessage = "Failed to update like: \(error.localizedDescription)"
        }
    }

    func loadTopTags(limit: Int? = nil, minCount: Int = 1) async {
        do {
            let reviews = try await reviewRepo.fetchReviewsForRestaurant(restaurantId, limit: 200)
            self.reviews = reviews
            
            // Compute averages
            let foodScores = reviews.compactMap { $0.foodScore }
            avgFoodScore = foodScores.isEmpty ? nil : foodScores.reduce(0, +) / Double(foodScores.count)

            let serviceScores = reviews.compactMap { $0.serviceScore }
            avgServiceScore = serviceScores.isEmpty ? nil : serviceScores.reduce(0, +) / Double(serviceScores.count)
            
            var counts: [String: Int] = [:]
            for r in reviews {
                let tags = (r.tags ?? [])
                for raw in tags {
                    let norm = normalizeTag(raw)
                    guard isAcceptable(norm) else { continue }
                    counts[norm, default: 0] += 1
                }
            }
            let ranked = counts
                .filter { $0.value >= minCount }
                .sorted { lhs, rhs in
                    if lhs.value != rhs.value { return lhs.value > rhs.value }
                    return lhs.key < rhs.key
                }
                .map { prettyTag($0.key) }
            if let limit {
                topTags = Array(ranked.prefix(limit))
            } else {
                topTags = ranked
            }
            await prefetchUsersForRecentReviews(limit: 2)
        } catch {
            // Non-fatal; leave empty
            topTags = []
            avgFoodScore = nil
            avgServiceScore = nil
        }
    }

    func prefetchUsersForRecentReviews(limit: Int = 2) async {
        // Sort reviews by createdAt desc and take top N userIds
        let sorted = reviews.sorted { lhs, rhs in
            let l = lhs.createdAt?.dateValue() ?? .distantPast
            let r = rhs.createdAt?.dateValue() ?? .distantPast
            return l > r
        }
        let ids = Array(Set(sorted.prefix(limit).map { $0.userId }))
        guard !ids.isEmpty else { return }

        // Fetch concurrently, skipping those we already have
        let missing = ids.filter { usersById[$0] == nil }
        guard !missing.isEmpty else { return }

        await withTaskGroup(of: (String, UserPublic?).self) { group in
            for id in missing {
                group.addTask { [userRepo] in
                    do {
                        let user = try await userRepo.fetchUser(id: id)
                        return (id, user)
                    } catch {
                        return (id, nil)
                    }
                }
            }
            var map: [String: UserPublic] = [:]
            for await (id, user) in group {
                if let user { map[id] = user }
            }
            // Merge into published dict
            for (k, v) in map { usersById[k] = v }
        }
    }

    // MARK: - Tag helpers
    private func normalizeTag(_ t: String) -> String {
        // Trim and lowercase first
        let lowered = t.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // Replace any sequence of non-alphanumeric characters with a single space
        let replaced = lowered.replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
        // Collapse multiple spaces and trim again
        let collapsed = replaced.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return collapsed
    }

    private func isAcceptable(_ t: String) -> Bool {
        let lengthOK = (2...24).contains(t.count)
        let deny: Set<String> = ["lol", "nsfw"]
        return lengthOK && !deny.contains(t)
    }

    private func prettyTag(_ t: String) -> String {
        guard let first = t.first else { return t }
        return String(first).uppercased() + t.dropFirst()
    }
}

