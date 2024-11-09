//
//  DatabaseManager.swift
//  HootMessenger
//
//  Created by nurdin affandi on 4/11/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class APIService: APIServicing {
    public static let shared = APIService()
    let database = Database.database(url: "https://hootmessenger-9fb48-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    let firebaseAuth = FirebaseAuth.Auth.auth()
    
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
    }
    
    func validateAuthorization() -> Bool {
        return firebaseAuth.currentUser == nil
    }
    
    // MARK: - Database
    
    /// Checks if user exists for given email
    /// Parameters
    /// - `email`:              Target email to be checked
    /// - `completion`:   Async closure to return with result
    public func userExists(
        with email: String,
        completion: @escaping ((Bool) -> Void)
    ) {
        let safeEmail = APIService.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(
            of: .value,
            with: { snapshot in
                guard snapshot.value as? [String: Any] != nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        )
    }
    
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
       
}

// MARK: - Utility
extension APIService {
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// MARK: - Errors
public enum APIError: Error {
    case userExists
    case createUserFail
    case genericError
}

