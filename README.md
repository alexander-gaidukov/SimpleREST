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

let webClient = WebClient(baseUrl: "<Your API server base url>")

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
```swift
let cahedWebClient = CachedWebClient(webClient: webClient)
let task = cahedWebClient.load(resource: resource,
forceUpdate = true (if you want to invalidate cache), false by default
cacheType = .permanent or .temporary(TimeInterval), .permanent by default
) { response in

}
```
If you need to clear cache storage use the following command:
```swift
Cache.clear()
```
You can also clear cache for specific resource or url path:
```swift
Cache.clear(forResource:)
Cache.clear(forPath:)
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
