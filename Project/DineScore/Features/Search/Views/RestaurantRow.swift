//
//  RestaurantRow.swift
//  DineScore
//
//  Created by Fernando Romo on 12/9/25.
//

import SwiftUI

struct RestaurantRow: View {
    let restaurant: RestaurantPublic
    
    var body: some View {
        HStack(spacing: 12) {
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
                            .font(.caption).bold()
                            .foregroundColor(.secondary)
                    }
                @unknown default:
                    Circle().fill(Color.gray.opacity(0.2))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.subheadline)
                    .bold()
//                Text("@\(user.username)")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
            }
            Spacer()
            //FollowButton(targetUserId: user.id)
        }
        .padding(.vertical, 6)
    }
    
    private func initial(from restaurant: RestaurantPublic) -> String {
        let n = restaurant.name.first.map { String($0) } ?? ""
        return (n).uppercased()
    }
}

