//
//  APIService+GoogleSignIn.swift
//  HootMessenger
//
//  Created by nurdin affandi on 5/12/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

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
