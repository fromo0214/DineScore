//
//  ImageUploader.swift
//  DineScore
//
//  Created by Fernando Romo on 8/12/25.
//

import Firebase
import FirebaseCore
import FirebaseStorage
import UIKit

final class ImageUploader {
    private let storage = Storage.storage()
    
    
    //function to upload restaurant images for restaurants
    func uploadRestaurantImage(_ image: UIImage,restaurantId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            return completion(.failure(NSError(domain:"image", code: 0, userInfo: [NSLocalizedDescriptionKey: "Bad image data"])))
        }
        
        let path = "restaurants/\(restaurantId)/cover.jpg"
        let ref = storage.reference(withPath: path)
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        ref.putData(data, metadata: meta){_, error in
            if let error = error {return completion(.failure(error))}
            ref.downloadURL() { url, err in
                if let err = err {return completion(.failure(err))}
                else if let url = url {completion(.success(url.absoluteString))}
                
            }
        }
    }
    
    //function to upload profile pictures
    func uploadProfileImage(_ image: UIImage, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            return completion(.failure(NSError(domain:"image", code: 0, userInfo: [NSLocalizedDescriptionKey: "Bad image data"])))
        }
        
        let path = "users/\(userId)/profile.jpg"
        let ref = storage.reference(withPath: path)
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        ref.putData(data, metadata: meta){_, error in
            if let error = error {return completion(.failure(error))}
            ref.downloadURL() { url, err in
                if let err = err {return completion(.failure(err))}
                else if let url = url {completion(.success(url.absoluteString))}
                
            }
        }
    }
}
