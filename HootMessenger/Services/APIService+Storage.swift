//
//  APIService+Storage.swift
//  HootMessenger
//
//  Created by nurdin affandi on 5/12/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

// MARK: Storage
extension APIService {
    public func storageUploadProfilePicture(with data: Data, fileName: String) async throws {
        return try await storage.uploadProfilePicture(with: data, fileName: fileName)
    }
    
    public func uploadProfilePictureRegister(image: UIImage, fileName: String) async throws {
        guard let imageData = image.pngData() else {
            throw StorageError.failedToUploadProfileImage
        }
        try await storageUploadProfilePicture(with: imageData, fileName: fileName)
    }
    
    public func uploadProfilePictureGoogleSignIn(user: ChatAppUser, googleUser: GIDGoogleUser) async throws {
        guard let profile = googleUser.profile, profile.hasImage else {
            throw StorageError.failedToGetGoogleProfileImage
        }
        
        let profileImgUrl = profile.imageURL(withDimension: 200)
        
        guard let profileImgUrl = profileImgUrl else {
            throw StorageError.failedToGetGoogleProfileImage
        }
        
        let imageData = try await retrieveImageData(url: profileImgUrl)
        let filename = user.profilePictureFileName
        try await storageUploadProfilePicture(
            with: imageData,
            fileName: filename
        )
    }
    
    public func uploadDefaultImage(user: ChatAppUser) async throws {
        let image = UIImage(systemName: "person.circle")?.withRenderingMode(.alwaysTemplate)
        guard let profileImage = image,
              let imageData = profileImage.pngData() else {
            throw StorageError.failedToUploadProfileImage
        }
        let fileName = user.profilePictureFileName
        try await storageUploadProfilePicture(
            with: imageData,
            fileName: fileName
        )
    }
    
    public func retrieveImageData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw StorageError.failedToGetGoogleProfileImage
        }
    }
    
    func downloadUrl(path: String) async throws -> URL {
        do {
            let url = try await storage.downloadURL(for: path)
            return url
        } catch {
            throw StorageError.failedToGetDownloadUrl
        }
    }
}
