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
    
    // US state abbreviations
    private let usStateAbbreviations: [String] = [
        "AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
        "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
        "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
        "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
        "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"
    ]
    
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
                        TextField("City", text: $vm.city)
                            .textInputAutocapitalization(.words)
                        
                        // State picker (abbreviations)
                        Picker("State", selection: $vm.state) {
                            Text("Select…").tag("")
                            ForEach(usStateAbbreviations, id: \.self) { abbr in
                                Text(abbr).tag(abbr)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        
                        TextField("Zip Code", text: $vm.zipCode)
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
