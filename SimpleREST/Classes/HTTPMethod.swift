//
//  HTTPMethod.swift
//  Pods-SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 21/10/2017.
//

import Foundation

public typealias JSON = [String: Any]
public typealias HTTPHeaders = [String: String]

public enum Body {
    case json(JSON)
    case multipart(params: JSON, attachments: [String: [Attachment]])
}

extension Body {
    
    func contentType(boundary: String) -> String {
        switch self {
        case .json:
            return "application/json"
        case .multipart:
            return "multipart/form-data; boundary=\(boundary)"
        }
    }
    
    func httpBody(boundary: String) -> Data? {
        switch self {
        case .json(let json):
            return jsonBody(params: json)
        case let .multipart(params, attachments):
            return multipartBody(params: params, attachments: attachments, boundary: boundary)
        }
    }
    
    private func jsonBody(params: JSON) -> Data {
        return try! JSONSerialization.data(withJSONObject: params, options: [])
    }
    
    private func multipartBody(params: JSON, attachments: [String: [Attachment]], boundary: String) -> Data? {
        var body = Data()
        
        params.forEach {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\($0.key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\($0.value)\r\n".data(using: .utf8)!)
        }
        
        attachments.forEach { element in
            element.value.forEach { attachment in
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(element.key)\"; filename=\"\(attachment.name)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: \(attachment.mimeType)\r\n\r\n".data(using: .utf8)!)
                body.append(attachment.data)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

public enum HTTPMethod {
    case get
    case post(Body?)
    case put(Body?)
    case delete
}

extension HTTPMethod {
    var value: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
    
    var body: Body? {
        switch self {
        case .post(let body):
            return body
        case .put(let body):
            return body
        default:
            return nil
        }
    }
}
