//
//  CombinedResource.swift
//  SimpleREST
//
//  Created by Alexandr Gaidukov on 23/07/2019.
//

import Foundation

public indirect enum CombinedResource<A, E: Error> {
    case value(A)
    case single(Resource<A, E>)
    case _sequence(CombinedResource<Any, E>, (Any) -> CombinedResource<A, E>)
    case _zipped(CombinedResource<Any, E>, CombinedResource<Any, E>, (Any, Any) -> A)
}

extension CombinedResource {
    var asAny: CombinedResource<Any, E> {
        switch self {
        case let .value(value):
            return .value(value)
        case let .single(resource):
            return .single(resource.map { $0 })
        case let ._sequence(resource, transform):
            return ._sequence(resource, { transform($0).asAny })
        case let ._zipped(left, right, transform):
            return ._zipped(left, right, { transform($0, $1) })
        }
    }
    
    public func flatMap<B>(_ transform: @escaping (A) -> CombinedResource<B, E>) -> CombinedResource<B, E> {
        return CombinedResource<B, E>._sequence(self.asAny) { transform($0 as! A) }
    }
    
    public func flatMap<B>(_ transform: @escaping (A) -> Resource<B, E>) -> CombinedResource<B, E> {
        return flatMap { transform($0).combined }
    }
    
    public func map<B>(_ transform: @escaping (A) -> B) -> CombinedResource<B, E> {
        switch self {
        case let .value(value):
            return .value(transform(value))
        case let .single(resource):
            return .single(resource.map(transform))
        case let ._sequence(resource, f):
            return ._sequence(resource) {
                f($0).map(transform)
            }
        case let ._zipped(left, right, f):
            return ._zipped(left, right) {
                transform(f($0, $1))
            }
        }
    }
    
    public func zipWith<B, C>(_ other: CombinedResource<B, E>, combine: @escaping (A, B) -> C) -> CombinedResource<C, E> {
        return CombinedResource<C, E>._zipped(self.asAny, other.asAny) { combine($0 as! A, $1 as! B) }
    }
    
    public func zipWith<B, C>(_ other: Resource<B, E>, combine: @escaping (A, B) -> C) -> CombinedResource<C, E> {
        return zipWith(other.combined, combine: combine)
    }
}

extension Resource {
    public var combined: CombinedResource<A, E> {
        return .single(self)
    }
    
    public func flatMap<B>(_ transform: @escaping (A) -> Resource<B, E>) -> CombinedResource<B, E> {
        return combined.flatMap(transform)
    }
    
    public func flatMap<B>(_ transform: @escaping (A) -> CombinedResource<B, E>) -> CombinedResource<B, E> {
        return combined.flatMap(transform)
    }
    
    public func zipWith<B, C>(_ other: Resource<B, E>, combine: @escaping (A, B) -> C) -> CombinedResource<C, E> {
        return combined.zipWith(other.combined, combine: combine)
    }
}
