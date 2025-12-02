//
//  UserProfileViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 9/23/25.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SwiftUI

@MainActor
final class UserProfileViewModel: ObservableObject{
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentUser: AppUser? = nil
    @Published var followerUsers: [AppUser] = []
    @Published var followingUsers: [AppUser] = []
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var pickedImage: UIImage?


    @Published var errorText: String?
    @Published var isSavingPhoto: Bool = false
    @Published var photoSaved: Bool = false

    
    private let db = Firestore.firestore()
    private let repo = AppUserRepository()
    private let uploader = ImageUploader()
    
    func loadSocials(for user: AppUser) async{
        followerUsers = await fetchUsers(ids: user.followers)
        followingUsers = await fetchUsers(ids: user.following)
    }
    
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
    
    // Upload avatar, update Firestore, and refresh local user
    func saveProfilePhoto() async {
        guard !isSavingPhoto else { return }
        
        guard let img = pickedImage else {
            errorMessage = "Please pick a photo first."
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Not signed in."
            return
        }
        
        isSavingPhoto = true
        defer { isSavingPhoto = false }
        
        do {
            let url = try await uploader.uploadUserAvatar(img, userId: uid)
            // Update Firestore with both internal and public field names
            try await db.collection("users").document(uid).setData([
                "profileImageURL": url,
                "profilePicture": url, // mirror for UserPublic
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
            
            if var user = currentUser {
                user.profileImageURL = url
                currentUser = user
            }
            photoSaved = true
            pickedImage = nil
            selectedPhoto = nil
            
        } catch {
            errorMessage = "Failed to save photo: \(error.localizedDescription)"
        }
    }
    
    
    //retrieves users followers/following ids at the same time
    private func fetchUsers(ids: [String]) async -> [AppUser]{
        //run child tasks on a background executor
        return await withTaskGroup(of: AppUser?.self) { group in
            //add one child task per user id
            for id in ids {
                //this runs for every task per user id, if it fails then return nil and skips it
                group.addTask{ do{
                    return try await self.repo.get(uid: id)
                }catch{
                    print("Failed to fetch \(id): \(error.localizedDescription)")
                    return nil
                }}
            }
            //Collect results as child finishes
            var results: [AppUser] = []
            for await user in group{
                if let user { results.append(user) }
            }
            return results  
        }
    }
    
    func updateCurrentUser(firstName: String, lastName: String, zipCode: String) async {
        guard var user = currentUser, let _ = user.id else { return }
        user.firstName = firstName
        user.lastName = lastName
        user.zipCode = zipCode
        do{
            try await repo.upsert(user: user)
            currentUser = user
        }catch{
            errorMessage = "Failed to update user: \(error.localizedDescription)"
        }
    }
    
    func getAppUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged-in user.")
            currentUser = nil
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let docRef = db.collection("users").document(uid)
            let snapshot = try await docRef.getDocument()
            
            if let user = try? snapshot.data(as: AppUser.self) {
                self.currentUser = user
            }else{
                print("User document not found")
            }
        }catch{
            print("Failed to load user: \(error.localizedDescription)")
        }
    }
}
