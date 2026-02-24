import SwiftUI

struct HomeContentView: View {
    @State private var showAddRestaurant = false
    @StateObject private var vm = SearchViewModel()
    @StateObject private var userVm = UserProfileViewModel()
    @State private var selectedUserId: String?
    @State private var isSearching = false
    @State private var selectedRestaurantId: String?
    @State private var featuredRestaurants: [RestaurantPublic] = []
    @State private var topRatedNearbyRestaurants: [RestaurantPublic] = []
    private let restaurantRepo = RestaurantRepository()
    private let defaultRestaurantListLimit = 6
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Logo Header
                    HStack {
                        Image("dineScoreSymbol")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(.leading, 60)
                            .foregroundColor(Color.accentColor)
                        Text("DineScore")
                            .bold()
                            .foregroundColor(Color.accentColor)
                            .font(.title)
                        Spacer()
                    }
                    .padding(.top, 1)
                    .padding(.leading, 16)
                    
                    if isSearching {
                        // Present search view instead of home content
                        SearchView(vm: vm, isSearching: $isSearching, selectedUserId: $selectedUserId, selectedRestaurantId: $selectedRestaurantId)
                            .frame(maxWidth: CGFloat.infinity)
                    } else {
                        // Home Content
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.accentColor)
                            TextField("Find restaurants, dishes, users...", text: $vm.searchText)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .foregroundColor(Color.accentColor)
                                .bold()
                                .placeholder(when: vm.searchText.isEmpty){
                                    Text("Find restaurants, dishes, users...")
                                        .foregroundColor(Color.accentColor)
                                        .bold()
                                }
                                .disabled(true) // Disable editing on the home screen
                        }
                        // Make the whole bar tappable to enter SearchView
                        .overlay(
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isSearching = true
                                }
                        )
                        .padding(.leading, 16)
                        .padding(.top, 5)
                        
                        Rectangle()
                            .frame(width: 360, height: 1)
                            .foregroundColor(Color.accentColor)
                        
                        // Search Bar Buttons
                        HStack {
                            ForEach([("Food", 60), ("Service", 70), ("Nearby", 70), ("Trending", 90)], id: \.0) { (title, width) in
                                Button {} label: {
                                    Text(title)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color.backgroundColor)
                                        .frame(width: CGFloat(width), height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .foregroundColor(Color.accentColor)
                                        )
                                }
                            }
                        }
                        
                        Button {
                            showAddRestaurant = true
                        } label: {
                            Image(systemName: "plus.app.fill")
                                .bold()
                                .font(.system(size: 40))
                        }
                        
                        // Featured Restaurants
                        HStack {
                            Text("Featured Restaurants").bold()
                            Spacer()
                        }.padding()
                        VStack {
                            if featuredRestaurants.isEmpty {
                                Text("No featured restaurants available.")
                                    .foregroundColor(Color.accentColor)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(featuredRestaurants, id: \.id) { restaurant in
                                            featuredRestaurantCard(restaurant)
                                        }
                                    }
                                }
                            }
                        }.padding()
                        
                        HStack {
                            Text("Top Rated Near You").bold()
                            Spacer()
                        }.padding()
                        VStack {
                            if let zipCode = normalizedUserZipCode {
                                if topRatedNearbyRestaurants.isEmpty {
                                    Text("No top-rated restaurants found for \(zipCode).")
                                        .foregroundColor(Color.accentColor)
                                } else {
                                    ForEach(topRatedNearbyRestaurants, id: \.id) { restaurant in
                                        restaurantListRow(restaurant)
                                    }
                                }
                            } else {
                                Text("Add your ZIP code in your profile to see nearby top-rated restaurants.")
                                    .foregroundColor(Color.accentColor)
                            }
                        }.padding()
                        
                        HStack {
                            Text("Favorited Restaurants").bold()
                            Spacer()
                        }.padding()
                        VStack {
                            if userVm.likedRestaurantDetails.isEmpty {
                                Text("You have no liked restaurants yet.")
                                    .foregroundColor(Color.accentColor)
                            } else {
                                ForEach(userVm.likedRestaurantDetails, id: \.id) { restaurant in
                                    restaurantListRow(restaurant)
                                }
                            }
                        }.padding()
                    }
                }
                .navigationBarBackButtonHidden(true)
                .frame(width: 350)
                .frame(maxWidth: .infinity)
                .sheet(isPresented: $showAddRestaurant) {
                    AddRestaurantView()
                }
                .navigationDestination(item: $selectedUserId) { userId in
                    PublicProfileView(userId: userId)
                }
                .navigationDestination(item: $selectedRestaurantId) {restaurantId in
                    RestaurantView(restaurantId: restaurantId)
                }
                .task {
                    await loadHomeLists()
                }
            }
        }
    }
    
    @MainActor
    private func loadHomeLists() async {
        await userVm.getAppUser()
        await userVm.refreshLikedRestaurants()
        
        do {
            featuredRestaurants = try await restaurantRepo.fetchFeaturedRestaurants(limit: defaultRestaurantListLimit)
        } catch {
            print("Failed to load featured restaurants: \(error.localizedDescription)")
            featuredRestaurants = []
        }
        
        if let zipCode = normalizedUserZipCode {
            do {
                topRatedNearbyRestaurants = try await restaurantRepo.fetchTopRatedRestaurants(zipCode: zipCode, limit: defaultRestaurantListLimit)
            } catch {
                print("Failed to load top-rated nearby restaurants: \(error.localizedDescription)")
                topRatedNearbyRestaurants = []
            }
        } else {
            topRatedNearbyRestaurants = []
        }
    }
    
    private func restaurantListRow(_ restaurant: RestaurantPublic) -> some View {
        return Button {
            guard let restaurantId = restaurant.id, !restaurantId.isEmpty else { return }
            selectedRestaurantId = restaurantId
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .foregroundColor(Color.backgroundColor)
                        .bold()
                    Text(formatLocation(city: restaurant.city, state: restaurant.state))
                        .foregroundColor(Color.backgroundColor)
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.backgroundColor)
            }
            .padding(.horizontal, 12)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(Color.accentColor)
            )
        }
    }
    
    private func featuredRestaurantCard(_ restaurant: RestaurantPublic) -> some View {
        Button {
            guard let restaurantId = restaurant.id, !restaurantId.isEmpty else { return }
            selectedRestaurantId = restaurantId
        } label: {
            ZStack(alignment: .bottomLeading) {
                let url = restaurant.coverPicture.flatMap { URL(string: $0) }
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty, .failure:
                        ZStack {
                            Color.accentColor.opacity(0.25)
                            Text(restaurant.name.first.map(String.init)?.uppercased() ?? "")
                                .font(.title)
                                .bold()
                                .foregroundColor(Color.backgroundColor.opacity(0.6))
                        }
                    @unknown default:
                        Color.accentColor.opacity(0.25)
                    }
                }
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.75)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .bold()
                        .lineLimit(2)
                    Text("Food \(formatScore(restaurant.avgFoodScore)) • Service \(formatScore(restaurant.avgServiceScore))")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(12)
            }
            .frame(width: 250, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private func formatScore(_ score: Double?) -> String {
        score.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? "--"
    }
    
    private func formatLocation(city: String?, state: String?) -> String {
        let cityValue = (city ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let stateValue = (state ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        switch (cityValue.isEmpty, stateValue.isEmpty) {
        case (false, false): return "\(cityValue), \(stateValue)"
        case (false, true): return cityValue
        case (true, false): return stateValue
        default: return ""
        }
    }
    
    private var normalizedUserZipCode: String? {
        guard let zipCode = userVm.currentUser?.zipCode?.trimmingCharacters(in: .whitespacesAndNewlines),
              !zipCode.isEmpty else { return nil }
        return zipCode
    }
}
