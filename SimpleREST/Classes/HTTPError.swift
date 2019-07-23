//
//  HTTPError.swift
//  SimpleREST
//
//  Created by Alexandr Gaidukov on 23/07/2019.
//

import Foundation

public enum HTTPError<E: Error>: Error {
    case noInternetConnection
    case responseParseError
    case serverUnavailable
    case custom(E)
    case other(Int)
}
