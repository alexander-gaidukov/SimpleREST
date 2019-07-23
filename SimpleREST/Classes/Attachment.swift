//
//  Attachment.swift
//  Pods-SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 23/07/2019.
//

import Foundation
import MobileCoreServices

public struct Attachment {
    public let data: Data
    public let mimeType: String
    public let name: String
}

extension Attachment {
    public init(path: String) throws {
        let url = URL(fileURLWithPath: path)
        
        do {
            self.data = try Data(contentsOf: url)
        } catch {
            throw error
        }
        
        self.name = url.lastPathComponent
        self.mimeType = Attachment.mimeType(for: path)
    }
    
    private static func mimeType(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}
