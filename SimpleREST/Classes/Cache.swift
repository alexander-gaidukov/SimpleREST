//
//  Cache.swift
//  RESTClient
//
//  Created by Alexandr Gaidukov on 19/10/2017.
//  Copyright © 2017 Alexander Gaidukov. All rights reserved.
//

import Foundation

extension Resource {
    var cacheKey: String {
        var result = "cache_" + path.absolutePath + "_"
        for key in params.keys.sorted() {
            result += "\(key)=\(String(describing: params[key]))"
        }
        return result
    }
}

private final class SRCache: NSCache<AnyObject, AnyObject> {
    
    private(set) var keys: Set<String> = []
    
    override func removeAllObjects() {
        super.removeAllObjects()
        keys.removeAll()
    }
    
    override func setObject(_ obj: AnyObject, forKey key: AnyObject) {
        super.setObject(obj, forKey: key)
        if let key  = key as? String {
            keys.insert(key)
        }
    }
    
    override func removeObject(forKey key: AnyObject) {
        super.removeObject(forKey: key)
        if let key = key as? String {
            keys.remove(key)
        }
    }
}

public final class Cache {
    
    static let shared: Cache = Cache()
    
    private var sessionCache: SRCache = SRCache()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(Cache.clearSessionCache), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func clearSessionCache() {
        Cache.clear()
    }
    
    public static func clear() {
        shared.sessionCache.removeAllObjects()
    }
    
    public static func clear<A, E>(forResource resource: Resource<A, E>) {
        shared.sessionCache.removeObject(forKey: resource.cacheKey as AnyObject)
    }
    
    public static func clear(forPath path: String) {
        let newPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        shared.sessionCache.keys.filter({ $0.contains(newPath) }).forEach {
            shared.sessionCache.removeObject(forKey: $0 as AnyObject)
        }
    }
    
    func load<A, E>(forResource resource: Resource<A, E>) -> A? {
        
        guard resource.method == .get else { return nil }
        
        guard let cacheItem = (sessionCache.object(forKey: resource.cacheKey as AnyObject)) as? CacheItem else {
            return nil
        }
        
        if let aliveTill = cacheItem.aliveTill, aliveTill.compare(Date()) == .orderedAscending {
            sessionCache.removeObject(forKey: cacheItem)
            return nil
        }
        
        return resource.parse(cacheItem.data)
    }
    
    func save<A, E>(_ data: Data, forResource resource: Resource<A, E>, type: CacheType = .permanent) {
        
        guard resource.method == .get else { return }
        
        let cacheItem = CacheItem(data: data, type: type)
        
        sessionCache.setObject(cacheItem, forKey: resource.cacheKey as AnyObject)
    }
}
