//
//  DatabaseManager.swift
//  HootMessenger
//
//  Created by nurdin affandi on 4/11/24.
//

import Foundation
import FirebaseDatabase

class APIService: APIServicing {
    public static let shared = APIService()
    var database = Database.database().reference()
}
