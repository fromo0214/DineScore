// UserSession.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class UserSession: ObservableObject {
    @Published var currentUser: AppUser?
    private var listener: ListenerRegistration?

    private let db = Firestore.firestore()

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

    func stop() {
        listener?.remove()
        listener = nil
        currentUser = nil
    }
}
