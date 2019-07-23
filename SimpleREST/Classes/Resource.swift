//
//  Resource.swift
//  Pods-SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 21/10/2017.
//

import Foundation

public struct CacheConfiguration {
    let key: String
    let liveTime: TimeInterval?
}

public struct Resource<A, E: Error> {
    public let url: URL
    public let params: JSON
    public let method: HTTPMethod
    public let headers: HTTPHeaders
    public let cacheConfiguration: CacheConfiguration?
    public let parse: (Data) -> A?
    public let parseError: (Data) -> E?
}

extension Resource where A: Decodable, E: Decodable {
    public init(baseURL: URL, path: String, params: JSON = [:], method: HTTPMethod = .get, headers: HTTPHeaders = [:], decoder: JSONDecoder) {
        var urlPath = path
        if urlPath.hasPrefix("/") { urlPath.removeFirst() }
        self.url = baseURL.appendingPathComponent(urlPath)
        self.params = params
        self.method = method
        self.headers = headers
        self.cacheConfiguration = nil
        self.parse = { try? decoder.decode(A.self, from: $0) }
        self.parseError = { try? decoder.decode(E.self, from: $0) }
    }
}

extension Resource {
    public func cacheable(key: String? = nil, liveTime: TimeInterval? = nil) -> Resource<A, E> {
        let cacheConfiguration = CacheConfiguration(key: key ?? cacheKey, liveTime: liveTime)
        return Resource(url: url, params: params, method: method, headers: headers, cacheConfiguration: cacheConfiguration, parse: parse, parseError: parseError)
    }
    
    private var cacheKey: String {
        var result = url.absoluteString
        let cacheParams = params.keys.sorted()
        for param in cacheParams {
            result.append("&\(param)=\(String(describing: params[param]))")
        }
        return result
    }
}



extension Resource {
    public func map<B>(_ transform: @escaping (A) -> B) -> Resource<B, E> {
        return Resource<B, E>(url: url, params: params, method: method, headers: headers, cacheConfiguration: cacheConfiguration, parse: { self.parse($0).map(transform) }, parseError: parseError)
    }
    
    public func compactMap<B>(_ transform: @escaping (A) -> B?) -> Resource<B, E> {
        return Resource<B, E>(url: url, params: params, method: method, headers: headers, cacheConfiguration: cacheConfiguration, parse: { self.parse($0).flatMap(transform) }, parseError: parseError)
    }
}
