# NimbusDisplayIOKit

A Nimbus SDK extension for **DisplayIO bidding and rendering**. It enriches Nimbus ad requests with DisplayIO demand and handles ad rendering through the DisplayIO SDK when it wins the auction.

## Versioning
 
NimbusDisplayIOKit **major versions are kept in sync** with the DisplayIO SDK. For example, NimbusDisplayIOKit `4.x.x` depends on DisplayIO SDK `4.x.x`.
 
Minor and patch versions are independent — a NimbusDisplayIOKit patch release does not necessarily correspond to a DisplayIO SDK patch release, and vice versa.
 
| NimbusDisplayIOKit | DisplayIO SDK |
|---|---|
| 4.x.x | 4.x.x |

## Installation

### Swift Package Manager

#### Xcode Project

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL:
   ```
   https://github.com/adsbynimbus/nimbus-ios-displayio
   ```
3. Set the dependency rule to **Up to Next Major Version** and enter `4.0.0` as the minimum.
4. Click **Add Package** and select the **NimbusDisplayIOKit** library when prompted.

#### Package.swift

If you're managing dependencies through a `Package.swift` file, add the following:

```swift
dependencies: [
    .package(url: "https://github.com/adsbynimbus/nimbus-ios-displayio", from: "4.0.0")
]
```

Then add the product to your target:

```swift
.product(name: "NimbusDisplayIOKit", package: "nimbus-ios-displayio")
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'NimbusDisplayIOKit'
```

Then run:

```sh
pod install
```

## Usage

### Initialization
 
Navigate to where you call `Nimbus.initialize` and register the `DisplayIOExtension`:
 
```swift
import NimbusDisplayIOKit

Nimbus.initialize(publisher: "<publisher>", apiKey: "<apiKey>") {
    DisplayIOExtension(appId: "<appId>", userId: "<optional-userId>")
}
```

If you provide an app ID, Nimbus will automatically initialize the DisplayIO SDK.

That's it — DisplayIO is now enabled in all upcoming requests.

## Documentation

- [Nimbus iOS SDK Documentation](https://docs.adsbynimbus.com/docs/sdk/ios) — integration guides, configuration, and API reference.
- [DocC API Reference](https://iosdocs.adsbynimbus.com) — auto-generated documentation for the latest release.

## Sample App

See NimbusDisplayIOKit in action in our public [sample app repository](https://github.com/adsbynimbus/nimbus-ios-sample), which demonstrates end-to-end integration including setup, bid requests, and ad rendering.
