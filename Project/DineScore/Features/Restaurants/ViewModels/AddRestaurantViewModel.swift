//
//  AddRestaurantViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 8/12/25.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore


//main actor runs code on the main thread, because it is touching UI or other main-thread-only stuff
//UI updates must happen on the main thread
@MainActor
final class AddRestaurantViewModel: ObservableObject{
    //form fields
    @Published var name: String = ""
    @Published var address: String = ""
    @Published var cuisine: String = ""
    @Published var priceLevel: Int = 1
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var pickedImage: UIImage?
    
    //ui state
    @Published var isSaving = false
    @Published var errorText: String?
    @Published var showDone = false
    
    
    private let repo = RestaurantRepository()
    private let uploader = ImageUploader()
    
    //used to enable/disable save button
    var isValid: Bool {
        //trims white spaces and ensures required fields are not empty
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !address.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    
    //turns the user's photopicker selection into a UIimage
    func loadPickedPhoto() async {
        guard let item = selectedPhoto else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data)
            {
                self.pickedImage = img
            }
        } catch {
            self.errorText = "Could not load image."
        }
    }
    
    func save(){
        //if the form is not valid (missing name/address) or we're already saving -> just stop
        guard isValid, !isSaving else { return }
        
        isSaving = true
        errorText = nil
        
        //unique ID so duplicate restaurants aren't created
        let key = Restaurant.normalizedKey(name: name, address: address)
        
        //create a restaurant object with all the fields from the form
        let base = Restaurant(id: nil, name: name.trimmingCharacters(in: .whitespaces), address: address.trimmingCharacters(in: .whitespaces), cuisine: cuisine, priceLevel: priceLevel, photoURL: nil, avgFoodScore: 0, avgFoodServiceScore: 0, reviewCount: 0, ownerId: "", status: "active", normalizedKey: key, latitutde: 0, longitude: 0, createdAt: nil, updatedAt: nil)
        
        //Ask firestore to store this restaurant in the repository
        //The repo will: check if a restaurant with this normalized key already exists
        
        repo.createRestaurantIfNeeded(base){ [weak self] //[weak self] used to not hold memory, creates a memory leak (retain cycle)
            result in
            guard let self = self else { return } //safety: avoid crashes if view goes away
            
            switch result {
                
            case .failure(let err):
                //something went wrong in firestore
                Task{@MainActor in
                    self.errorText = err.localizedDescription
                    self.isSaving = false
                }
                
            case .success(let id):
                //restaurant is now saved in firestore with ID = normalizedKey
                
                //if user didn't pick photo
                guard let img = self.pickedImage else {
                    Task {@MainActor in
                        self.isSaving = false
                        self.showDone = true //trigger alert in UI
                    }
                    return
                }
                
                self.uploader.uploadRestaurantImage(img, restaurantId: id){ upRes in
                    switch upRes{
                    case .failure(let e):
                        //restaurant saved but photo upload failed.
                        Task {@MainActor in
                            self.errorText = e.localizedDescription
                            self.isSaving = false
                            self.showDone = true
                        }
                        
                        
                    case .success(let url):
                        //got download url from storage, now patch firestore with it
                        Firestore.firestore().collection("restaurants").document(id).updateData(["photoURL": url, "updatedAt" : FieldValue.serverTimestamp()]){_ in
                            Task {@MainActor in
                                self.isSaving = false
                                self.showDone = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}
