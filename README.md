# SimpleREST

[![CI Status](http://img.shields.io/travis/alexander-gaidukov/SimpleREST.svg?style=flat)](https://travis-ci.org/alexander-gaidukov/SimpleREST)
[![Version](https://img.shields.io/cocoapods/v/SimpleREST.svg?style=flat)](http://cocoapods.org/pods/SimpleREST)
[![License](https://img.shields.io/cocoapods/l/SimpleREST.svg?style=flat)](http://cocoapods.org/pods/SimpleREST)
[![Platform](https://img.shields.io/cocoapods/p/SimpleREST.svg?style=flat)](http://cocoapods.org/pods/SimpleREST)

## Overview
Simple REST is a RESTful client with ability to cache response data.

## How to use

```swift
let webClient = WebClient(baseUrl: "<Your API server base url>")

let resource = Resource<Object, CustomError>(path: "/resource_path",
method: .get,
params: ["param1": "value1", "param2": "value2"],
headers: ["headerField1": "value1"],
parse: { (data: Data) -> Object in
    return <Object instance from raw json data>
},
parseError: { (data: Data) -> CustomError
    return <CustomError instance from raw json data>
})

let task = webClient.load(resource: resource) { response in
    if let object = response.value {
        // handle object
    } else {
        // handle response.error
    }
}
```

### Task cancelling

```swift
task?.cancel()
```

### Codable objects (iOS 11)
If your Object and CustomError conform to `Codable` protocol you can create a `Resource` object in a simpler way

```swift
let resource = Resource<Object, CustomError>(path: "/resource_path",
method: .get,
params: ["param1": "value1", "param2": "value2"],
headers: ["headerField1": "value1"])
```
### Common parameters and headers
If you need to add some common parameters or headers to all requests (`access_token` for instance), you can do this in the following way:

```swift
webClient.commonParams["access_token"] = "12345"
webClient.commonHeaders["access_token"] = "12345"
```

### Caching
```swift
let cahedWebClient = CachedWebClient(webClient: webClient)
let task = cahedWebClient.load(resource: resource,
forceUpdate = true (if you want to invalidate cache), false by default
cacheAliveDuration = time interval or nil for permanent cache, nil by default
) { response in

}
```
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* ARC
* iOS 11

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
