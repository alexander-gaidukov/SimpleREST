//
//  Cache.swift
//  RESTClient
//
//  Created by Alexandr Gaidukov on 19/10/2017.
//  Copyright © 2017 Alexander Gaidukov. All rights reserved.
//

import UIKit

public final class HTTPCache {
    public static let shared = HTTPCache()
    private var cache: [String: CacheItem] = [:]
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(clear), name: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    public func save<A, E: Error>(data: Data, for resource: Resource<A, E>) {
        guard let cacheConfiguration = resource.cacheConfiguration else { return }
        let item = CacheItem(value: data, expirationDate: cacheConfiguration.liveTime.map { Date(timeIntervalSinceNow: $0) })
        cache[cacheConfiguration.key] = item
    }
    
    public func clearCache<A, E: Error>(for resource: Resource<A, E>) {
        guard let key = resource.cacheConfiguration?.key else { return }
        cache.removeValue(forKey: key)
    }
    
    @objc public func clear() {
        cache.removeAll()
    }
    
    func item<A, E: Error>(for resource: Resource<A, E>) -> CacheItem? {
        guard let key = resource.cacheConfiguration?.key, let item = cache[key] else {
            return nil
        }
        
        if let expirationDate = item.expirationDate, expirationDate < Date() {
            cache.removeValue(forKey: key)
            return nil
        }
        
        return item
    }
}
