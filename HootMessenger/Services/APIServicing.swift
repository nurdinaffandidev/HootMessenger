//
//  APIServicing.swift
//  HootMessenger
//
//  Created by nurdin affandi on 4/11/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn

protocol APIServicing {
    var database: DatabaseReference { get }
    var firebaseAuth: Auth { get }
    
    // MARK: - Auth
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult
    func logout() throws
    func validateAuthorization() -> Bool
    // MARK: - Database
    func userExists(with email: String) async -> Bool
    func insertUser(with user: ChatAppUser) async throws
    // MARK: - Google Sign In
    func signInWithGoogle(presentOver viewController: UIViewController) async -> GIDGoogleUser?
    // MARK: - Storage
    func storageUploadProfilePicture(with data: Data, fileName: String) async throws
    func uploadProfilePictureRegister(image: UIImage, fileName: String) async throws
    func uploadProfilePictureGoogleSignIn(user: ChatAppUser, googleUser: GIDGoogleUser) async throws
    func uploadDefaultImage(user: ChatAppUser) async throws
    func retrieveImageData(url: URL) async throws -> Data
    func downloadUrl(path: String) async throws -> URL
}
