//
//  ProfileTableViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 9/11/24.
//

import Foundation

enum ProfileTableViewCellModelType {
    case info, logout
}

struct ProfileTableViewCellModel {
    let viewModelType: ProfileTableViewCellModelType
    let title: String
    let handler: (() -> Void)?
}
