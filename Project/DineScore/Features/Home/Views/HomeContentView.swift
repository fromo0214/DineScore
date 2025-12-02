import SwiftUI

struct HomeContentView: View {
    @State private var showAddRestaurant = false
    @StateObject private var vm = SearchViewModel()
    @State private var selectedUserId: String?
    @State private var isSearching = false
    
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
                        SearchView(vm: vm, isSearching: $isSearching, selectedUserId: $selectedUserId)
                            .frame(maxWidth: CGFloat.infinity)
                    } else {
                        // Home Content
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.accentColor)
                            TextField("Search restaurants, dishes, ...", text: $vm.searchText)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .foregroundColor(Color.accentColor)
                                .bold()
                                .placeholder(when: vm.searchText.isEmpty){
                                    Text("Search restaurants, dishes, ...")
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
                            HStack {
                                Text("Featured Restaurants")
                                    .foregroundColor(Color.backgroundColor)
                                    .frame(width: 180, height: 80)
                                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color.accentColor))
                            }
                        }.padding()
                        
                        HStack {
                            Text("Top Rated Near You").bold()
                            Spacer()
                        }.padding()
                        VStack {
                            HStack {
                                Text("Restaurants")
                                    .foregroundColor(Color.backgroundColor)
                                    .frame(width: 150, height: 80)
                                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color.accentColor))
                            }
                        }.padding()
                        
                        HStack {
                            Text("Favorited Restaurants").bold()
                            Spacer()
                        }.padding()
                        VStack {
                            HStack {
                                Text("Favorited Restaurants")
                                    .foregroundColor(Color.backgroundColor)
                                    .frame(width: 180, height: 80)
                                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color.accentColor))
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
            }
        }
    }
}
