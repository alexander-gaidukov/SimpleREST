//
//  CacheItem.swift
//  RESTClient
//
//  Created by Alexandr Gaidukov on 19/10/2017.
//  Copyright © 2017 Alexander Gaidukov. All rights reserved.
//

import Foundation

struct CacheItem {
    let value: Data
    let expirationDate: Date?
}
