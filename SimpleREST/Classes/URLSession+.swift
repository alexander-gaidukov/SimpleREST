//
//  URLSession+.swift
//  SimpleREST
//
//  Created by Alexandr Gaidukov on 23/07/2019.
//

import Foundation

extension URL {
    init<A, E>(resource: Resource<A, E>) {
        var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)!
        var queryItems: JSON = [:]
        components.queryItems?.forEach {
            queryItems[$0.name] = $0.value
        }
        queryItems.merge(resource.params) { $1 }
        components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        self = components.url!
    }
}

extension URLRequest {
    init<A, E>(resource: Resource<A, E>) {
        let url = URL(resource: resource)
        self.init(url: url)
        httpMethod = resource.method.value
        let boundary = createBoundary()
        httpBody = resource.method.body?.httpBody(boundary: boundary)
        resource.headers.forEach { setValue(String(describing: $0.value), forHTTPHeaderField: $0.key) }
        setValue("application/json", forHTTPHeaderField: "Accept")
        setValue(resource.method.body?.contentType(boundary: boundary) ?? "application/json", forHTTPHeaderField: "Content-Type")
    }
    
    private func createBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}

extension URLSession {
    @discardableResult
    public func load<A, E: Error>(resource: Resource<A, E>, completion: @escaping (Result<A, HTTPError<E>>) -> ()) -> URLSessionDataTask? {
        
        if let cachedItem = HTTPCache.shared.item(for: resource) {
            completion(resource.parse(cachedItem.value).map{ .success($0) } ?? .failure(.responseParseError))
            return nil
        }
        
        let request = URLRequest(resource: resource)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                switch (error as? URLError)?.code {
                case .cancelled?:
                    ()
                case .notConnectedToInternet?, .networkConnectionLost?:
                    completion(.failure(.noInternetConnection))
                default:
                    completion(.failure(.serverUnavailable))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.serverUnavailable))
                return
            }
            
            if (200..<300) ~= httpResponse.statusCode {
                if let result = data.flatMap(resource.parse) {
                    HTTPCache.shared.save(data: data!, for: resource)
                    completion(.success(result))
                } else {
                    completion(.failure(.responseParseError))
                }
            } else {
                let err: HTTPError = data.flatMap(resource.parseError).map{ .custom($0) } ?? .other(httpResponse.statusCode)
                completion(.failure(err))
            }
        }
        
        task.resume()
        
        return task
    }
}

extension URLSession {
    @discardableResult
    public func load<A, E: Error>(combinedResource: CombinedResource<A, E>, completion: @escaping (Result<A, HTTPError<E>>) -> ()) -> URLSessionDataTask? {
        switch combinedResource {
        case let .value(value):
            completion(.success(value))
            return nil
        case let .single(resource):
            return load(resource: resource, completion: completion)
        case let ._sequence(resource, transform):
            load(combinedResource: resource) { result in
                switch result {
                case let .success(value):
                    self.load(combinedResource: transform(value), completion: completion)
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        case let ._zipped(left, right, transform):
            let group = DispatchGroup()
            var resultA: Result<Any, HTTPError<E>>!
            var resultB: Result<Any, HTTPError<E>>!
            group.enter()
            load(combinedResource: left) {
                resultA = $0
                group.leave()
            }
            group.enter()
            load(combinedResource: right) {
                resultB = $0
                group.leave()
            }
            
            group.notify(queue: .global()) {
                switch (resultA, resultB) {
                case let (.success(value1)?, .success(value2)?):
                    completion(.success(transform(value1, value2)))
                case let (.failure(error)?, _):
                    completion(.failure(error))
                case let (_, .failure(error)?):
                    completion(.failure(error))
                default:
                    fatalError("Unexpected result")
                }
            }
        }
        return nil
    }
}
