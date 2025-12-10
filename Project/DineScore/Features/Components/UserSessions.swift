// UserSession.swift
//UserSession listens to the Firestore users/{uid} document for the currently authenticated user
//and exposes it as currentUser to your SwiftUI views, starting/stopping that live connection
//with start() and stop().

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class UserSession: ObservableObject {
    @Published var currentUser: AppUser?
    private var listener: ListenerRegistration?

    private let db = Firestore.firestore()

    //Checks if someone is logged in, UI changes react instantly to any changes in user document
    func start() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // Live listener returns cached data immediately (if available) and then server updates
        listener = db.collection("users").document(uid).addSnapshotListener { [weak self] snap, error in
            guard let self = self else { return }
            if let snap, snap.exists {
                self.currentUser = try? snap.data(as: AppUser.self)
            }
        }
    }

    //call this during log out
    func stop() {
        listener?.remove()
        listener = nil
        currentUser = nil
    }
}
