import SwiftUI

struct SearchView: View {
    @ObservedObject var vm: SearchViewModel
    @Binding var isSearching: Bool
    @Binding var selectedUserId: String?
    
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        VStack {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.accentColor)
                TextField("Search restaurants, dishes, ...", text: $vm.searchText)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .foregroundColor(Color.accentColor)
                    .bold()
                    .placeholder(when: vm.searchText.isEmpty) {
                        Text("Search restaurants, dishes, ...")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }
                    .focused($isSearchFieldFocused)
                Button("Cancel") {
                    // Clear focus first so the keyboard dismisses smoothly
                    isSearchFieldFocused = false
                    vm.searchText = ""
                    isSearching = false
                }
                .foregroundColor(.accentColor)
            }
            .padding([.horizontal, .top])
            .onAppear {
                // Auto-focus when the search view appears
                // Dispatch to next run loop to ensure the view is on screen
                DispatchQueue.main.async {
                    isSearchFieldFocused = true
                }
            }
            
            Rectangle()
                .frame(width: 360, height: 1)
                .foregroundColor(Color.accentColor)
            
            // Loading/Error/Results
            if vm.isLoading {
                ProgressView().padding(.top, 16)
            } else if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage).foregroundColor(.red).padding(.top, 16)
            } else if vm.results.isEmpty, !vm.searchText.isEmpty {
                Text("Nothing found!").foregroundColor(.accentColor).padding(.top, 16)
            } else if !vm.results.isEmpty {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(vm.results) { user in
                        Button { selectedUserId = user.id } label: {
                            UserRow(user: user)
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .background(Color.backgroundColor.ignoresSafeArea())
    }
}
