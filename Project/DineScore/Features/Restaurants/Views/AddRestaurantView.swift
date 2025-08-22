//
//  AddRestaurantView.swift
//  DineScore
//
//  Created by Fernando Romo on 8/19/25.
//

import SwiftUI
import PhotosUI

struct AddRestaurantView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddRestaurantViewModel()
    
    
    var body: some View {
        ZStack{
            Color.backgroundColor.ignoresSafeArea()
            
            NavigationStack{
                Form{
                    Section("Basics"){
                        TextField("Name", text: $vm.name)
                            .textInputAutocapitalization(.words)
                        TextField("Address", text: $vm.address)
                            .textInputAutocapitalization(.words)
                        TextField("Cuisine (e.g., Mexican, Sushi)", text: $vm.cuisine)
                            .textInputAutocapitalization(.words)
                        Picker("Price Level", selection: $vm.priceLevel) {
                            ForEach(1...4, id: \.self) { level in
                                Text(String(repeating: "$", count: level)).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                    }
                    
                    Section("Photo (optional)") {
                        PhotosPicker(selection: $vm.selectedPhoto, matching: .images) {
                            Label("Pick Cover Photo", systemImage: "photo")
                        }
                        if let img = vm.pickedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    if let err = vm.errorText {
                        Section{ Text(err).foregroundColor(.red) }
                    }
                    
                }.navigationTitle("Add Restaurant")
                    .toolbar{
                        ToolbarItem(placement: .topBarLeading){
                            Button("Cancel") { dismiss() }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing){
                            Button(vm.isSaving ? "Saving..." : "Save" ) { vm.save() }
                                .disabled(!vm.isValid || vm.isSaving)
                        }
                    }
                    .onChange(of: vm.selectedPhoto){_, _ in
                        Task { await vm.loadPickedPhoto() }
                    }
                    .alert("Restaurant saved", isPresented: $vm.showDone){
                        Button("OK") { dismiss() }
                    } message: {
                        Text("Your restaurant has been added.")
                    }
                    
            }
            
        }
    }
}

#Preview {
    AddRestaurantView()
}
