# FastXML

A Fast and Swifty [XML](https://www.w3.org/TR/2006/REC-xml11-20060816/) parser written in [Swift](https://swift.org)

[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/Carthage/Carthage/master/LICENSE.md)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/Dohko/FastXML.svg?branch=master)](https://travis-ci.org/Dohko/FastXML)
![Platform](https://img.shields.io/badge/platforms-iOS%208.0+%20%7C%20macOS%2010.10+%20%7C%20tvOS%209.0+%20%7C%20watchOS%202.0+-333333.svg)

## Requirements

- Swift 4.0+ | iOS 8.0+ | macOS 10.10+ | tvOS 9.0+ | watchOS 2.0+
- Xcode 8 or later

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `FastXML` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
    pod 'FastXML', '~> 1.2.0'
end
```

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/FastXML.framework` to an iOS project.

```
github "Dohko/FastXML" ~> 1.2.0
```

#### Manually
Download and Drag/Drop ```FastXML.swift``` and ```Tag.swift``` into your project.

####Swift Package Manager
You can use [The Swift Package Manager](https://swift.org/package-manager) to install `FastXML` by adding the proper description to your `Package.swift` file:
```swift
import PackageDescription

let package = Package(
    name: "PROJECT_NAME",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/dohko/FastXML.git", majorVersion: 1, minor: 2)
    ]
)
```

## License

FastXML is released under the MIT license:

* https://opensource.org/licenses/MIT


## Support

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/FastXML). (Tag 'FastXML')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/FastXML).
- If you **found a bug**, _and can provide steps to reliably reproduce it_, [open an issue](https://github.com/dohko/FastXML/issues/new).
- If you **have a feature request**, [open an issue](https://github.com/dohko/FastXML/issues/new).
- If you **want to contribute**, [submit a pull request](https://github.com/dohko/FastXML/compare).
