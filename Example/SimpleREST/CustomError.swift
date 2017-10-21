//
//  CustomError.swift
//  SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 21/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

struct CustomError: Error, Decodable {
    var message: String
}
