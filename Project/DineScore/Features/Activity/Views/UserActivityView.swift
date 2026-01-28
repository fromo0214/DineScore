//
//  UserActivityView.swift
//  DineScore
//
//  Created for recent activity feature
//

import SwiftUI

struct UserActivityView: View {
    let activities: [UserActivity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if activities.isEmpty {
                Text("No recent activity")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding()
            } else {
                ForEach(activities.prefix(5)) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
}

struct ActivityRow: View {
    let activity: UserActivity
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon based on activity type
            Image(systemName: iconName)
                .foregroundColor(Color.accentColor)
                .font(.system(size: 20))
            
            // Activity description
            VStack(alignment: .leading, spacing: 4) {
                Text(activityDescription)
                    .foregroundColor(Color.textColor)
                    .font(.system(size: 14))
                
                Text(timeAgo)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var iconName: String {
        switch activity.type {
        case .likedRestaurant:
            return "heart.fill"
        case .likedReview:
            return "heart.fill"
        case .createdReview:
            return "star.fill"
        }
    }
    
    private var activityDescription: String {
        switch activity.type {
        case .likedRestaurant:
            if let name = activity.restaurantName {
                return "Liked \(name)"
            }
            return "Liked a restaurant"
        case .likedReview:
            return "Liked a review"
        case .createdReview:
            if let name = activity.restaurantName {
                return "Reviewed \(name)"
            }
            return "Wrote a review"
        }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: activity.timestamp, relativeTo: Date())
    }
}

#Preview {
    let sampleActivities = [
        UserActivity(
            id: "1",
            userId: "user1",
            type: .likedRestaurant,
            restaurantId: "rest1",
            restaurantName: "The Fancy Restaurant",
            reviewId: nil,
            createdAt: nil
        ),
        UserActivity(
            id: "2",
            userId: "user1",
            type: .createdReview,
            restaurantId: "rest2",
            restaurantName: "Burger Place",
            reviewId: "review1",
            createdAt: nil
        )
    ]
    
    UserActivityView(activities: sampleActivities)
}
