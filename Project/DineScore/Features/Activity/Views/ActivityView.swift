import SwiftUI
import Combine
import FirebaseFirestore

struct ActivityView: View {

    @EnvironmentObject private var session: UserSession
    @State private var selectedTab: ActivityTab = .friends
    @StateObject private var viewModel = ActivityViewModel()

    enum ActivityTab: String, CaseIterable, Identifiable {
        case friends = "Friends"
        case you = "You"
        var id: String { self.rawValue }
    }

    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("Activity")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.backgroundColor)
                    Spacer()
                }
                .padding()
                .background(Color.textColor)

                Picker("Activity Tab", selection: $selectedTab) {
                    ForEach(ActivityTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                            .foregroundColor(.accentColor)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                List {
                    ForEach(viewModel.displayedActivity(for: selectedTab)) { item in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(Color.accentColor)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.actorName)
                                    .font(.headline)
                                    .foregroundColor(Color.accentColor)
                                Text(item.actionText)
                                    .font(.subheadline)
                                    .foregroundColor(Color.accentColor)
                                Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .listRowBackground(Color.backgroundColor)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .task(id: session.currentUser?.id) {
            await viewModel.startLiveUpdates(currentUser: session.currentUser)
        }
        .onChange(of: session.currentUser?.following) { _ in
            Task { await viewModel.startLiveUpdates(currentUser: session.currentUser) }
        }
        .onDisappear { viewModel.stopLiveUpdates() }
    }
}

struct ActivityItem: Identifiable, Equatable {
    let id: String
    let actorName: String
    let actionText: String
    let date: Date
}

@MainActor
final class ActivityViewModel: ObservableObject {
    @Published private(set) var youActivity: [ActivityItem] = []
    @Published private(set) var friendsActivity: [ActivityItem] = []
    private let activityRepo = ActivityRepository()
    private let userRepo = AppUserRepository()
    private var youListener: ListenerRegistration?
    private var friendsListener: ListenerRegistration?
    private var usersById: [String: UserPublic] = [:]
    private var currentUserId: String?

    func startLiveUpdates(currentUser: AppUser?) async {
        stopLiveUpdates()
        guard let userId = currentUser?.id else {
            youActivity = []
            friendsActivity = []
            return
        }

        currentUserId = userId
        let followingIds = currentUser?.following.filter { $0 != userId } ?? []

        youListener = activityRepo.listenRecentActivities(
            userId: userId,
            limit: 20,
            onUpdate: { [weak self] activities in
                Task { await self?.handleUpdates(activities, defaultName: "You", target: .you) }
            },
            onError: { error in
                print("Error listening for your activity: \(error.localizedDescription)")
            }
        )

        guard !followingIds.isEmpty else {
            friendsActivity = []
            return
        }

        friendsListener = activityRepo.listenRecentActivities(
            userIds: followingIds,
            limit: 20,
            onUpdate: { [weak self] activities in
                Task { await self?.handleUpdates(activities, defaultName: nil, target: .friends) }
            },
            onError: { error in
                print("Error listening for friends activity: \(error.localizedDescription)")
            }
        )
    }

    func stopLiveUpdates() {
        youListener?.remove()
        friendsListener?.remove()
        youListener = nil
        friendsListener = nil
    }

    func displayedActivity(for tab: ActivityView.ActivityTab) -> [ActivityItem] {
        let source = (tab == .you) ? youActivity : friendsActivity
        return source.sorted { $0.date > $1.date }
    }
    
    private func handleUpdates(
        _ activities: [UserActivity],
        defaultName: String?,
        target: ActivityTarget
    ) async {
        let ids = Array(Set(activities.map { $0.userId }))
        await prefetchUsers(for: ids)

        let currentId = currentUserId
        let items = activities.map { activity in
            let actorName: String
            if let defaultName, activity.userId == currentId {
                actorName = defaultName
            } else if let user = usersById[activity.userId] {
                actorName = user.displayNameShort
            } else {
                actorName = "Someone"
            }
            let fallbackId = "\(activity.userId)-\(activity.timestamp.timeIntervalSince1970)"
            return ActivityItem(
                id: activity.id ?? fallbackId,
                actorName: actorName,
                actionText: actionText(for: activity),
                date: activity.timestamp
            )
        }

        switch target {
        case .you:
            youActivity = items
        case .friends:
            friendsActivity = items
        }
    }

    private func prefetchUsers(for ids: [String]) async {
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
            for (id, user) in map {
                usersById[id] = user
            }
        }
    }

    private func actionText(for activity: UserActivity) -> String {
        switch activity.type {
        case .likedRestaurant:
            let name = activity.restaurantName ?? "a restaurant"
            return "liked \(name)"
        case .likedReview:
            if let name = activity.restaurantName {
                return "liked a review for \(name)"
            }
            return "liked a review"
        case .createdReview:
            let name = activity.restaurantName ?? "a restaurant"
            return "reviewed \(name)"
        }
    }
}

private enum ActivityTarget {
    case you
    case friends
}

#Preview {
    ActivityView()
        .environmentObject(UserSession())
}
