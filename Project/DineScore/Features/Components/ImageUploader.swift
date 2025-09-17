import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseCore

enum ImageUploaderError: LocalizedError {
    case jpegEncoding
    case missingURL
    var errorDescription: String? {
        switch self {
        case .jpegEncoding: return "Could not encode image as JPEG."
        case .missingURL:   return "downloadURL returned nil."
        }
    }
}

final class ImageUploader {

    // MARK: - Public API (async)
    /// Uploads a cover image and returns the HTTPS download URL string.
    @MainActor
    func uploadRestaurantCover(_ image: UIImage, restaurantId: String) async throws -> String {
        // sanity printouts to catch common config issues
        let uid = Auth.auth().currentUser?.uid ?? "nil"
        let bucket = FirebaseApp.app()?.options.storageBucket ?? "nil"
        print("[Uploader] user uid=\(uid), bucket=\(bucket)")

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw ImageUploaderError.jpegEncoding
        }

        let ref = restaurantCoverRef(restaurantId: restaurantId)
        print("[Uploader] PUT to: \(ref.fullPath)")

        // Upload
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"

        do {
            // ⚠️ If this throws, it's a true PUT failure (rules / auth / bucket)
            _ = try await ref.putDataAsync(data, metadata: meta)
            print("[Uploader] putDataAsync OK")
        } catch {
            // On real put errors you'll see .unauthorized/.unauthenticated/.quotaExceeded/etc.
            print("[Uploader] putDataAsync ERROR: \(error.localizedDescription) (\((error as NSError).code))")
            // Try to list folder to see what's there (debug only)
            await debugListFolder(restaurantId: restaurantId)
            throw error
        }

        // Get URL (separate step so we know which call fails)
        do {
            let url = try await ref.downloadURL()
            print("[Uploader] downloadURL OK: \(url.absoluteString)")
            return url.absoluteString
        } catch {
            print("[Uploader] downloadURL ERROR: \(error.localizedDescription) (\((error as NSError).code))")
            // Try to fetch metadata as an additional check
            do {
                let _ = try await ref.getMetadata()
                print("[Uploader] getMetadata OK (object exists)")
            } catch {
                print("[Uploader] getMetadata ERROR: \(error.localizedDescription) (\((error as NSError).code))")
            }
            await debugListFolder(restaurantId: restaurantId)
            throw error
        }
    }

    // MARK: - ViewModel helper (callback wrapper if you prefer)
    func uploadRestaurantImage(_ image: UIImage,
                               restaurantId: String,
                               completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let url = try await uploadRestaurantCover(image, restaurantId: restaurantId)
                completion(.success(url))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Path Builders
    private func restaurantFolderRef(restaurantId: String) -> StorageReference {
        let folder = slugify(restaurantId)
        return Storage.storage().reference().child("restaurants").child(folder)
    }

    private func restaurantCoverRef(restaurantId: String) -> StorageReference {
        restaurantFolderRef(restaurantId: restaurantId).child("cover.jpg")
    }

    // MARK: - Debug helpers
    private func slugify(_ s: String) -> String {
        s.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    /// Print bucket contents for this restaurant folder to verify what exists.
    @MainActor
    private func debugListFolder(restaurantId: String) async {
        let folder = restaurantFolderRef(restaurantId: restaurantId)
        do {
            let listing = try await folder.listAll()
            let items = listing.items.map { $0.fullPath }
            let prefixes = listing.prefixes.map { $0.fullPath }
            print("[Uploader] listAll prefixes:", prefixes)
            print("[Uploader] listAll items:", items)
        } catch {
            print("[Uploader] listAll ERROR:", error.localizedDescription, "(\((error as NSError).code))")
        }
    }
}
