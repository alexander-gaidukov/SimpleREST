//
//  APIError.swift
//  SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 31/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct APIError: Error, Decodable {
    let message: String
}
