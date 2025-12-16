import SwiftUI

struct SearchView: View {
    @ObservedObject var vm: SearchViewModel
    @Binding var isSearching: Bool
    @Binding var selectedUserId: String?
    @Binding var selectedRestaurantId: String?
    
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        VStack {
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.accentColor)
                
                TextField("Find restaurants, dishes, users...", text: $vm.searchText)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(Color.accentColor)
                    .bold()
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .placeholder(when: vm.searchText.isEmpty) {
                        Text("Find restaurants, dishes, users...")
                            .foregroundColor(Color.accentColor)
                            .bold()
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .focused($isSearchFieldFocused)
                
                Button("Cancel") {
                    // Clear focus first so the keyboard dismisses smoothly
                    isSearchFieldFocused = false
                    vm.searchText = ""
                    vm.userResults = []
                    vm.restaurantResults = []
                    isSearching = false
                }
                .foregroundColor(.accentColor)
                .lineLimit(1)
            }
            .frame(height: 44)
            .padding(.horizontal)
            .padding(.top)
            .onAppear {
                // Auto-focus when the search view appears
                DispatchQueue.main.async {
                    isSearchFieldFocused = true
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.accentColor)
                .padding(.horizontal)
            
            // Scope Picker
            Picker("Scope", selection: $vm.scope) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Loading/Error/Results
            if vm.isLoading {
                ProgressView().padding(.top, 16)
            } else if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage).foregroundColor(.red).padding(.top, 16)
            } else {
                contentForScope()
            }

            Spacer()
        }
        .background(Color.backgroundColor.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func contentForScope() -> some View {
        let hasQuery = !vm.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        switch vm.scope {
        case .users:
            if vm.userResults.isEmpty, hasQuery {
                Text("No users found").foregroundColor(.accentColor).padding(.top, 16)
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(vm.userResults) { user in
                        Button {
                            selectedUserId = user.id
                        } label: {
                            UserRow(user: user)
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
            
        case .restaurants:
            if vm.restaurantResults.isEmpty, hasQuery {
                Text("No restaurants found").foregroundColor(.accentColor).padding(.top, 16)
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(vm.restaurantResults) { r in
                        Button {
                            selectedRestaurantId = r.id
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.accentColor)
                                VStack(alignment: .leading) {
                                    Text(r.name)
                                        .foregroundColor(.accentColor)
                                        .bold()
                                    if let address = r.address, !address.isEmpty {
                                        Text(address)
                                            .font(.footnote)
                                            .foregroundColor(.accentColor.opacity(0.8))
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
