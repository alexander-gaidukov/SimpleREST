//
//  WebError.swift
//  Pods-SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 21/10/2017.
//

import Foundation

public enum WebError<CustomError>: Error {
    case noInternetConnection
    case serverUnavailable
    case custom(CustomError)
    case unauthorized
    case wrongDataFormat
    case other(Int, Error?)
}
