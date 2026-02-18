//
//  CreateListView.swift
//  DineScore
//
//  Created for restaurant list feature
//

import SwiftUI

struct CreateListView: View {
    @ObservedObject var vm: RestaurantListViewModel
    @Binding var isPresented: Bool
    
    @State private var listName = ""
    @State private var listDescription = ""
    @State private var isCreating = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("List Name")
                            .font(.headline)
                            .foregroundColor(.textColor)
                        TextField("e.g., Date Night Spots", text: $listName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.headline)
                            .foregroundColor(.textColor)
                        TextEditor(text: $listDescription)
                            .frame(height: 100)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Create List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        Task {
                            await createList()
                        }
                    }
                    .disabled(listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
                }
            }
            .alert("Error", isPresented: .constant(!errorMessage.isEmpty), actions: {
                Button("OK") { errorMessage = "" }
            }, message: {
                Text(errorMessage)
            })
        }
    }
    
    private func createList() async {
        let trimmedName = listName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        isCreating = true
        defer { isCreating = false }
        
        do {
            let description = listDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            try await vm.createList(name: trimmedName, description: description.isEmpty ? nil : description)
            isPresented = false
        } catch {
            errorMessage = "Failed to create list: \(error.localizedDescription)"
        }
    }
}
