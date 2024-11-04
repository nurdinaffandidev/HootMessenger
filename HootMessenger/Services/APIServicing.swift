//
//  APIServicing.swift
//  HootMessenger
//
//  Created by nurdin affandi on 4/11/24.
//

import Foundation
import FirebaseDatabase

protocol APIServicing {
    var database: DatabaseReference { get }
}
