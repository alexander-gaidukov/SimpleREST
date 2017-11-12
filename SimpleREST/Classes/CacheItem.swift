//
//  CacheItem.swift
//  RESTClient
//
//  Created by Alexandr Gaidukov on 19/10/2017.
//  Copyright © 2017 Alexander Gaidukov. All rights reserved.
//

import Foundation

public enum CacheType {
    case permanent
    case temporary(TimeInterval)
}

final class CacheItem {
    var data: Data
    var aliveTill: Date?
    
    init(data: Data, type: CacheType) {
        self.data = data
        switch type {
        case .permanent:
            self.aliveTill = nil
        case .temporary(let interval):
            self.aliveTill = Date().addingTimeInterval(interval)
        }
    }
}
