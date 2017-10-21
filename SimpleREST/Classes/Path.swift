//
//  Path.swift
//  Pods-SimpleREST_Example
//
//  Created by Alexandr Gaidukov on 21/10/2017.
//

import Foundation

struct Path {
    private var components: [String]
    
    var absolutePath: String {
        return "/" + components.joined(separator: "/")
    }
    
    init(_ path: String) {
        components = path.components(separatedBy: "/").filter({ !$0.isEmpty })
    }
    
    mutating func append(path: Path) {
        components += path.components
    }
    
    func appending(path: Path) -> Path {
        var copy = self
        copy.append(path: path)
        return copy
    }
}
