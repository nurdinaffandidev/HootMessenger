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
    let firebaseAuth = FirebaseAuth.Auth.auth()
    let clientID = FirebaseApp.app()?.options.clientID
    let storage = StorageManager()
    
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
    
    // MARK: - Database (Account Mgmt)
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
    
    /// Gets all users from database
    public func getAllUsers() async throws -> [[String: String]] {
        return try await withCheckedThrowingContinuation { continuation in
            database.child("users").observeSingleEvent(of: .value) { snapshot in
                if let value = snapshot.value as? [[String: String]] {
                    continuation.resume(returning: value)
                } else {
                    continuation.resume(throwing: DatabaseError.failedToFetchUserCollection)
                }
            }
        }
    }
    
    // MARK: - Database (Convo)
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
    case failedToFetchUserCollection
}

