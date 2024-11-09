//
//  APIServicing.swift
//  HootMessenger
//
//  Created by nurdin affandi on 4/11/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

protocol APIServicing {
    var database: DatabaseReference { get }
    var firebaseAuth: Auth { get }
    func userExists(with email: String, completion: @escaping ((Bool) -> Void))
    // MARK: - Auth
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult
    func logout() throws
    func validateAuthorization() -> Bool
    // MARK: - Database
    func insertUser(with user: ChatAppUser)
}
