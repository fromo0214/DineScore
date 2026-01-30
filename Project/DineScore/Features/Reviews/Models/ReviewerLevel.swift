import Foundation

enum ReviewerBadge: String, CaseIterable, Hashable {
    case serviceSleuth = "Service Sleuth 🔍"
    case flavorHunter = "Flavor Hunter 😋"
    case taster = "Taster 🍴"
}

struct ReviewerStats {
    let reviewCount: Int
    let completedReviewCount: Int
}

struct ReviewerLevel {
    let badge: ReviewerBadge
    let level: Int
    let summary: String
}

enum ReviewerLevelCalculator {
    static func stats(from reviews: [Review]) -> ReviewerStats {
        let completedReviews = reviews.filter { $0.isDetailComplete }
        return ReviewerStats(
            reviewCount: reviews.count,
            completedReviewCount: completedReviews.count
        )
    }

    static func level(for stats: ReviewerStats) -> ReviewerLevel {
        if stats.reviewCount >= 12 || stats.completedReviewCount >= 8 {
            return ReviewerLevel(
                badge: .serviceSleuth,
                level: 3,
                summary: "Detailed reviews with consistent service notes."
            )
        }
        if stats.reviewCount >= 6 || stats.completedReviewCount >= 4 {
            return ReviewerLevel(
                badge: .flavorHunter,
                level: 2,
                summary: "Growing reviewer with solid notes."
            )
        }
        return ReviewerLevel(
            badge: .taster,
            level: 1,
            summary: "New reviewer getting started."
        )
    }

    static func level(from reviews: [Review]) -> ReviewerLevel {
        level(for: stats(from: reviews))
    }

    static func badgeList(for level: ReviewerLevel) -> [ReviewerBadge] {
        switch level.level {
        case 3:
            return ReviewerBadge.allCases
        case 2:
            return [.flavorHunter, .taster]
        default:
            return [.taster]
        }
    }

}
