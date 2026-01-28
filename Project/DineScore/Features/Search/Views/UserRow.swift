// Features/Search/UserRow.swift
import SwiftUI

struct UserRow: View {
    let user: UserPublic
    
    var body: some View {
        HStack(spacing: 12) {
            let url = user.profilePicture.flatMap { URL(string: $0) }
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
                        Text(initials(from: user))
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
                Text(user.displayNameShort)
                    .font(.subheadline)
                    .bold()
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let userId = user.id {
                QuickFollowButton(targetUserId: userId)
            }
        }
        .padding(.vertical, 6)
    }
    
    private func initials(from user: UserPublic) -> String {
        let f = user.firstName.first.map { String($0) } ?? ""
        let l = user.lastName.first.map { String($0) } ?? ""
        return (f + l).uppercased()
    }
}

