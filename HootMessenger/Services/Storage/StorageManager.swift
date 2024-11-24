//
//  StorageManager.swift
//  HootMessenger
//
//  Created by nurdin affandi on 22/11/24.
//

import Foundation
import FirebaseStorage

final class StorageManager {
//    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    init() {}
    /*
     /images/afraz9-gmail-com_profile_picture.png
     */
    
    /// Uploads picture to firebase storage and url string to download
    public func uploadProfilePicture(with data: Data, fileName: String) async throws {
        do {
            // Upload the file
            _ = try await storage.child("images/\(fileName)").putDataAsync(data, metadata: nil)

            // Retrieve the download URL
            let url = try await storage.child("images/\(fileName)").downloadURL()
            let urlString = url.absoluteString
            print("download url returned: \(urlString)")
        } catch {
            print("Failed to upload data to Firebase or get download URL: \(error)")
            throw StorageError.failedToUploadProfileImage
        }
    }
}

public enum StorageError: Error {
    case failedToUploadProfileImage
    case failedToGetDownloadUrl
    case failedToGetGoogleProfileImage
}
