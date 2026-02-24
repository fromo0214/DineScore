import SwiftUI
import Combine
import FirebaseAuth

struct ActivityView: View {

    @State private var selectedTab: ActivityTab = .friends
    @StateObject private var viewModel = ActivityViewModel(
        fetchYou: { await ActivityAPI.fetchYouActivity() },
        fetchFriends: { await ActivityAPI.fetchFriendsActivity() }
    )

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
        .task(id: ActivityTaskKey(userId: session.currentUser?.id,
                                  following: session.currentUser?.following ?? [])) {
            await viewModel.startLiveUpdates(currentUser: session.currentUser)
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

    private let fetchYou: () async -> [ActivityItem]
    private let fetchFriends: () async -> [ActivityItem]
    private var timerCancellable: AnyCancellable?
    private var activeUserId: String?

    init(
        fetchYou: @escaping () async -> [ActivityItem],
        fetchFriends: @escaping () async -> [ActivityItem]
    ) {
        self.fetchYou = fetchYou
        self.fetchFriends = fetchFriends
    }

    func startLiveUpdates() async {
        let userId = Auth.auth().currentUser?.uid
        if activeUserId != userId {
            activeUserId = userId
            youActivity = []
            friendsActivity = []
        }
        await refresh(for: userId)
        timerCancellable = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let userId = Auth.auth().currentUser?.uid
                if self.activeUserId != userId {
                    self.activeUserId = userId
                    self.youActivity = []
                    self.friendsActivity = []
                }
                Task { await self.refresh(for: userId) }
            }
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

    private func refresh(for userId: String?) async {
        guard let userId else {
            youActivity = []
            friendsActivity = []
            return
        }
        async let you = fetchYou()
        async let friends = fetchFriends()
        let refreshedYou = await you
        let refreshedFriends = await friends
        guard activeUserId == userId else { return }
        youActivity = refreshedYou
        friendsActivity = refreshedFriends
    }
}

enum ActivityAPI {
    static func fetchYouActivity() async -> [ActivityItem] {
        // Replace with real backend call
        return [
            .init(id: "y1", actorName: "You", actionText: "reviewed Sushi Place", date: Date().addingTimeInterval(-600)),
            .init(id: "y2", actorName: "You", actionText: "liked Taco Spot", date: Date().addingTimeInterval(-1200))
        ]
    }

    static func fetchFriendsActivity() async -> [ActivityItem] {
        // Replace with real backend call
        return [
            .init(id: "f1", actorName: "Alex", actionText: "reviewed House Pasta", date: Date().addingTimeInterval(-300)),
            .init(id: "f2", actorName: "Jordan", actionText: "liked Burger Joint", date: Date().addingTimeInterval(-1800))
        ]
    }
}

#Preview {
    ActivityView()
        .environmentObject(UserSession())
}
