import SwiftUI

struct UserListsView: View {
    @StateObject private var vm = RestaurantListViewModel()
    @State private var showCreateList = false
    @State private var newListName = ""
    @State private var newListDescription = ""

    var body: some View {
        ZStack(){
            Color.backgroundColor
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 0){
                // This header will appear below any parent navigation bar
                HStack {
                    Text("My Lists")
                        .foregroundColor(Color.backgroundColor)
                        .bold()
                    Spacer()
                    Button(action: {
                        showCreateList = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.backgroundColor)
                            .padding()
                            .bold()
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 44) // typical bar height
                .background(Color.textColor)

                if vm.isLoading {
                    ProgressView("Loading lists...")
                        .padding()
                } else if vm.lists.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No lists yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Create a list to organize your favorite restaurants")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(vm.lists) { list in
                            NavigationLink(destination: ListDetailView(list: list, vm: vm)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(list.name)
                                        .font(.headline)
                                        .foregroundColor(.textColor)
                                    if let description = list.description, !description.isEmpty {
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    Text("\(list.restaurantIds.count) restaurant\(list.restaurantIds.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteList)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .task {
            await vm.fetchLists()
        }
        .sheet(isPresented: $showCreateList) {
            CreateListView(vm: vm, isPresented: $showCreateList)
        }
        .alert("Error", isPresented: .constant(!vm.errorMessage.isEmpty), actions: {
            Button("OK") { vm.errorMessage = "" }
        }, message: {
            Text(vm.errorMessage)
        })
    }
    
    private func deleteList(at offsets: IndexSet) {
        for index in offsets {
            let list = vm.lists[index]
            Task {
                await vm.deleteList(list)
            }
        }
    }
}
