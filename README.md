# SimpleREST

[![CI Status](http://img.shields.io/travis/alexander-gaidukov/SimpleREST.svg?style=flat)](https://travis-ci.org/alexander-gaidukov/SimpleREST)
[![Version](https://img.shields.io/cocoapods/v/SimpleREST.svg?style=flat)](http://cocoapods.org/pods/SimpleREST)
[![License](https://img.shields.io/cocoapods/l/SimpleREST.svg?style=flat)](http://cocoapods.org/pods/SimpleREST)
[![Platform](https://img.shields.io/cocoapods/p/SimpleREST.svg?style=flat)](http://cocoapods.org/pods/SimpleREST)

## Overview
Simple REST is a RESTful client with ability to cache response data.

## How to use

### Simple request

```swift

struct Object: Decodable {
// some properties here
}

struct APIError: Error, Decodable {
// some properties here
}

let resource = Resource<Object, CustomError>(baseURL: URL(string: "https://...")!
path: "resource_path",
params: ["param1": "value1", "param2": "value2"],
method: .get,
headers: ["headerField1": "value1"],
decoder: JSONDecoder())

let task = URLSession.shared.load(resource: resource) { result in
    switch result {
    case .success(let object):
        // handle object
    case .failure(let error):
        // handle error
    }
}
```

### Send data in the request body

For `application/json` data:
```swift
let resource = Resource<Object, CustomError>(baseURL: URL(string: "https://...")!
path: "resource_path",
params: [:],
method: .post(.json(["param1": "value1", "param2": "value2"])),
headers: ["headerField1": "value1"],
decoder: JSONDecoder())
```

For `multipart/form-data` data:
```swift
let attachment = try! Attachment(path: <path to file>)
let attachments = ["images": [attachment]]

let resource = Resource<Object, CustomError>(baseURL: URL(string: "https://...")!
path: "resource_path",
params: [:],
method: .post(.multipart(params: ["param1": "value1", "param2": "value2"], attachments: attachments)),
headers: ["headerField1": "value1"],
decoder: JSONDecoder())
```


### Task cancelling

```swift
task?.cancel()
```

### Caching

To use cache:

```swift
let resource = Resource<Object, CustomError>(baseURL: URL(string: "https://...")!
path: "resource_path",
params: ["param1": "value1", "param2": "value2"],
method: .get,
headers: ["headerField1": "value1"],
decoder: JSONDecoder())

let cacheableResource = resource.cacheable()

let task = URLSession.shared.load(resource: cacheableResource) { result in
    switch result {
    case .success(let object):
        // handle object
    case .failure(let error):
        // handle error
    }
}
```

You can specify cache key if you don't want to use the default one (path + all parameters) and cache live time (permanent by default)

```swift
let cacheableResource = resource.cacheable(key: "custom_key", liveTime: 60)
```

If you need to clear cache storage use the following command:
```swift
HTTPCache.shared.clear()
```
You can also clear cache for specific resource:
```swift
HTTPCache.shared.clearCache(for:)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* ARC
* iOS 9.0+

## Installation

SimpleREST is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SimpleREST'
```

## Author

alexander-gaidukov, alexander.gaidukov@gmail.com

## License

SimpleREST is available under the MIT license. See the LICENSE file for more info.
