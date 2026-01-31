//
//  AddToListView.swift
//  DineScore
//
//  Created for restaurant list feature
//

import SwiftUI
import FirebaseAuth

struct AddToListView: View {
    let restaurantId: String
    let restaurantName: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = RestaurantListViewModel()
    
    @State private var showCreateList = false
    @State private var isAdding = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if vm.isLoading {
                        ProgressView("Loading lists...")
                            .padding()
                        Spacer()
                    } else if vm.lists.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No lists yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Create your first list to organize restaurants")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Create List") {
                                showCreateList = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        Spacer()
                    } else {
                        List {
                            ForEach(vm.lists) { list in
                                Button(action: {
                                    Task {
                                        await addToList(list)
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(list.name)
                                                .font(.headline)
                                                .foregroundColor(.textColor)
                                            if let description = list.description, !description.isEmpty {
                                                Text(description)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                        
                                        if list.restaurantIds.contains(restaurantId) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else {
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .disabled(list.restaurantIds.contains(restaurantId))
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Add to List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateList = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await vm.fetchLists()
            }
            .sheet(isPresented: $showCreateList) {
                CreateListView(vm: vm, isPresented: $showCreateList)
            }
            .alert("Success", isPresented: .constant(!successMessage.isEmpty), actions: {
                Button("OK") {
                    successMessage = ""
                    dismiss()
                }
            }, message: {
                Text(successMessage)
            })
            .alert("Error", isPresented: .constant(!errorMessage.isEmpty), actions: {
                Button("OK") { errorMessage = "" }
            }, message: {
                Text(errorMessage)
            })
        }
    }
    
    private func addToList(_ list: RestaurantList) async {
        guard let listId = list.id else { return }
        
        isAdding = true
        defer { isAdding = false }
        
        do {
            try await vm.addRestaurantToList(listId: listId, restaurantId: restaurantId)
            successMessage = "Added '\(restaurantName)' to '\(list.name)'"
        } catch {
            errorMessage = "Failed to add to list: \(error.localizedDescription)"
        }
    }
}
