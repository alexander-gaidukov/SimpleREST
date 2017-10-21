//
//  User.swift
//  SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 21/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

struct User: Decodable {
    var id: String
    var email: String
    var name: String
}

struct FriendsResponse: Decodable {
    var friends: [User]
}
