//
//  Response.swift
//  Pods-SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 21/10/2017.
//

import Foundation

public enum Result<A, CustomError> {
    case success(A)
    case failure(WebError<CustomError>)
}

extension Result {
    init(value: A?, or error: WebError<CustomError>) {
        guard let value = value else {
            self = .failure(error)
            return
        }
        
        self = .success(value)
    }
    
    public var value: A? {
        guard case let .success(value) = self else { return nil }
        return value
    }
    
    public var error: WebError<CustomError>? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}
