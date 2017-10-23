//
//  Resource.swift
//  Pods-SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 21/10/2017.
//

import Foundation

public struct Resource<A, CustomError> {
    let path: Path
    let method: RequestMethod
    var params: JSON
    var headers: HTTPHeaders
    let parse: (Data) -> A?
    let parseError: (Data) -> CustomError?
}

extension Resource {
    public init(path: String,
         method: RequestMethod = .get,
         params: JSON = [:],
         headers: HTTPHeaders = [:],
         parse: @escaping (Data) -> A?,
         parseError: @escaping (Data) -> CustomError? = {_ in return nil}) {
        
        self.path = Path(path)
        self.method = method
        self.params = params
        self.headers = headers
        self.parse = parse
        self.parseError = parseError
    }
}

extension Resource where A: Decodable, CustomError: Decodable {
    public init(jsonDecoder: JSONDecoder,
         path: String,
         method: RequestMethod = .get,
         params: JSON = [:],
         headers: HTTPHeaders = [:]) {
        
        var newHeaders = headers
        newHeaders["Accept"] = "application/json"
        newHeaders["Content-Type"] = "application/json"
        
        self.path = Path(path)
        self.method = method
        self.params = params
        self.headers = newHeaders
        self.parse = {
            try? jsonDecoder.decode(A.self, from: $0)
        }
        self.parseError = {
            try? jsonDecoder.decode(CustomError.self, from: $0)
        }
    }
}
