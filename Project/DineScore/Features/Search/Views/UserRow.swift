// Features/Search/UserRow.swift
import SwiftUI

struct UserRow: View {
    let user: UserPublic
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: user.profilePicture ?? "")) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.2))
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
            //FollowButton(targetUserId: user.id)
        }
        .padding(.vertical, 6)
    }
}
