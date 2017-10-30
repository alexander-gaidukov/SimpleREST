//
//  WebClient.swift
//  Pods-SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 21/10/2017.
//

import Foundation

extension URL {
    init<A, E>(baseUrl: String, resource: Resource<A, E>) {
        var components = URLComponents(string: baseUrl)!
        components.path = Path(components.path).appending(path: resource.path).absolutePath
        
        switch resource.method {
        case .get, .delete:
            components.queryItems = resource.params.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        default:
            break
        }
        
        self = components.url!
    }
}

extension URLRequest {
    init<A, E>(baseUrl: String, resource: Resource<A, E>) {
        let url = URL(baseUrl: baseUrl, resource: resource)
        self.init(url: url)
        httpMethod = resource.method.rawValue
        resource.headers.forEach{
            setValue($0.value, forHTTPHeaderField: $0.key)
        }
        switch resource.method {
        case .post, .put:
            httpBody = try! JSONSerialization.data(withJSONObject: resource.params, options: [])
        default:
            break
        }
    }
}

open class WebClient {
    private var baseUrl: String
    
    public var commonParams: JSON = [:]
    public var commonHeaders: HTTPHeaders = [:]
    
    public init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    public func load<A, CustomError>(resource: Resource<A, CustomError>,
                                     completion: @escaping (Result<A, CustomError>) ->()) -> URLSessionDataTask? {
        
        if !Reachability.isConnectedToNetwork() {
            completion(.failure(.noInternetConnection))
            return nil
        }
        
        var newResouce = resource
        newResouce.params = newResouce.params.merging(commonParams) { spec, common in
            return spec
        }
        newResouce.headers = newResouce.headers.merging(commonHeaders) {spec, common in
            return spec
        }
        
        let request = URLRequest(baseUrl: baseUrl, resource: newResouce)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Parsing incoming data
            let httpResponse = response as! HTTPURLResponse
            
            if (200..<300) ~= httpResponse.statusCode {
                completion(Result(value: data.flatMap(resource.parse), or: .wrongDataFormat))
            } else if httpResponse.statusCode == 401 {
                completion(.failure(.unauthorized))
            } else {
                let err = data.flatMap(resource.parseError).map({ WebError.custom($0) }) ?? WebError.other(httpResponse.statusCode, error)
                completion(.failure(err))
            }
        }
        
        task.resume()
        
        return task
        
    }
}
