//
//  DatabaseManager.swift
//  HootMessenger
//
//  Created by nurdin affandi on 4/11/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class APIService: APIServicing {
    public static let shared = APIService()
    let database = Database.database(url: "https://hootmessenger-9fb48-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    internal let firebaseAuth = FirebaseAuth.Auth.auth()
    private let clientID = FirebaseApp.app()?.options.clientID
    private let storage = StorageManager()
    
    // MARK: - Auth
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult {
        let response = try await firebaseAuth.createUser(withEmail: email, password: password)
        return response
    }
    
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult {
        let response = try await firebaseAuth.signIn(withEmail: email, password: password)
        return response
    }
    
    func logout() throws {
        try firebaseAuth.signOut()
        logoutGoogleId()
    }
    
    func validateAuthorization() -> Bool {
        return firebaseAuth.currentUser == nil
    }
    
    // MARK: - Database
    /// Checks if user exists for given email
    public func userExists(with email: String) async -> Bool {
        let safeEmail = CommonUtils.safeEmail(emailAddress: email)
        
        return await withCheckedContinuation { continuation in
            database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
                if snapshot.value as? [String: Any] != nil {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser) async throws {
        let userData: [String: String] = [
            "first_name": user.firstName,
            "last_name": user.lastName
        ]
        
        let _ = await withCheckedContinuation { continuation in
            database.child(user.safeEmail).setValue(userData) { error, _ in
                if let error = error {
                    print("Failed to write to database: \(error)")
                    continuation.resume(returning: { throw DatabaseError.failedToInsert })
                } else {
                    continuation.resume(returning: {})
                }
            }
        }

        var usersCollection = await withCheckedContinuation { continuation in
            database.child("users").observeSingleEvent(of: .value) { snapshot, _  in
                if let usersCollection = snapshot.value as? [[String: String]] {
                    continuation.resume(returning: usersCollection)
                } else {
                    continuation.resume(returning: [[String: String]]())
                }
            }
        }

        if !usersCollection.isEmpty {
            // Append to existing users collection
            let newUser = [
                "name": "\(user.firstName) \(user.lastName)",
                "email": user.safeEmail
            ]
            usersCollection.append(newUser)

            let _ = await withCheckedContinuation { continuation in
                database.child("users").setValue(usersCollection) { error, _ in
                    if let error = error {
                        print("Failed to update users collection: \(error)")
                        continuation.resume(returning: { throw DatabaseError.failedToUpdateUserCollection })
                    } else {
                        continuation.resume(returning: {})
                    }
                }
            }
        } else {
            // Create new users collection
            let newUserCollection: [[String: String]] = [
                [
                    "name": "\(user.firstName) \(user.lastName)",
                    "email": user.safeEmail
                ]
            ]

            let _ = await withCheckedContinuation { continuation in
                database.child("users").setValue(newUserCollection) { error, _ in
                    if let error = error {
                        print("Failed to create users collection: \(error)")
                        continuation.resume(returning: { throw DatabaseError.failedToCreateUserCollection })
                    } else {
                        continuation.resume(returning: {})
                    }
                }
            }
        }
    }
    
}

// MARK: - Google Sign In
extension APIService {
    public func signInWithGoogle(presentOver viewController: UIViewController) async -> GIDGoogleUser? {
        guard let clientID = clientID else {
          fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                return nil
            }
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: accessToken.tokenString
            )
            
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            return user
        }
        catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func logoutGoogleId() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    public func restorePreviousSignIn() {
//        GIDSignIn.sharedInstance.restorePreviousSignIn(completion: <#T##((GIDGoogleUser?, (any Error)?) -> Void)?##((GIDGoogleUser?, (any Error)?) -> Void)?##(GIDGoogleUser?, (any Error)?) -> Void#>)
    }
}

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

// MARK: - Errors
public enum APIError: Error {
    case userExists
    case createUserFail
    case genericError
    case authTokenError
}

public enum DatabaseError: Error {
    case failedToInsert
    case failedToUpdateUserCollection
    case failedToCreateUserCollection
}

