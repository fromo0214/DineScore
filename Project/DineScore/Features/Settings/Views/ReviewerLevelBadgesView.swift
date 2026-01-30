import SwiftUI

struct ReviewerLevelBadgesView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = UserProfileViewModel()

    private var level: ReviewerLevel? {
        vm.reviewerLevel
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    if let level {
                        Text(level.badge.rawValue)
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.textColor)
                        Text("Level \(level.level)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(level.summary)
                            .foregroundColor(Color.textColor)
                            .padding(.bottom, 8)

                        Text("Badges Earned")
                            .font(.headline)
                            .foregroundColor(Color.accentColor)
                        ForEach(ReviewerLevelCalculator.badgeList(for: level), id: \.self) { badge in
                            Text(badge.rawValue)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(12)
                        }
                    } else {
                        Text("Loading Level…")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.textColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.backgroundColor)
                            .bold()
                        Text("Account")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Level & Badges")
                    .foregroundColor(Color.backgroundColor)
                    .font(.system(size: 20, weight: .bold))
                    .frame(height: 20)
            }
        }
        .task {
            await vm.getAppUser()
            await vm.refreshMyReviews()
        }
    }
}
