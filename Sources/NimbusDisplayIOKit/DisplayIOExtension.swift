//
//  DisplayIOExtension.swift
//  NimbusDisplayIOKit
//  Created on 7/10/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit
import DIOSDK

/// Nimbus extension for DisplayIO.
///
/// Enables DisplayIO rendering when included in `Nimbus.initialize(...)`.
/// Supports dynamic enable/disable at runtime.
///
/// ### Notes:
///   - Instantiate within the `Nimbus.initialize` block; the extension is installed and enabled automatically.
///   - Disable rendering with `DisplayIOExtension.disable()`.
///   - Re-enable rendering with `DisplayIOExtension.enable()`.
public struct DisplayIOExtension: NimbusRequestExtension, NimbusRenderExtension {
    @_documentation(visibility: internal)
    public var interceptor: any NimbusRequest.Interceptor
    
    @_documentation(visibility: internal)
    public var enabled = true
    
    @_documentation(visibility: internal)
    public var network: String { "displayiosdk" }
    
    @_documentation(visibility: internal)
    public var controllerType: AdController.Type { DisplayIOAdController.self }
    
    /// Creates a DisplayIO extension.
    ///
    /// - Parameter appId: If passed, Nimbus will initialize DisplayIO automatically
    /// - Parameter userId: Optional parameter passed to DisplayIO's initialization
    ///
    /// ##### Usage
    /// ```swift
    /// Nimbus.initialize(publisher: "<publisher>", apiKey: "<apiKey>") {
    ///     DisplayIOExtension(appId: "<appId>">, userId: "<userId>") // Enables DisplayIO rendering
    /// }
    /// ```
    public init(appId: String? = nil, userId: String? = nil) {
        self.interceptor = DisplayIORequestInterceptor()
        
        guard let appId else {
            Nimbus.Log.lifecycle.debug("Skipping DisplayIO SDK initialization, appId was not provided")
            return
        }
        
        DIOController.sharedInstance().initialize(withAppId: appId, userId: userId) {
            Nimbus.Log.lifecycle.debug("DisplayIO SDK initialization completed")
        } errorHandler: { error in
            Nimbus.Log.lifecycle.error("DisplayIO SDK initialization failed: \(error.localizedDescription)")
        }
    }
    
    @_documentation(visibility: internal)
    public func coppaDidChange(coppa: Bool) {
        // No-op, managed S2S
    }
}

public extension DisplayIOExtension {
    /// The UIView returned from this method should have all of the data set from the native ad
    /// on children views such as the call to action, image data, title, etc.
    /// The view returned from this method should NOT be attached to the container passed in as
    /// it will be attached at a later time during the rendering process.
    ///
    /// DO NOT call `nativeAd.registerView` method. Nimbus SDK will call it later.
    ///
    /// - Parameters:
    ///   - container: The container the layout will be attached to
    ///   - nativeAd: DisplayIO's DIONativeAdInterface ad type
    ///
    /// - Returns: Your custom UIView. DO NOT attach the view to the hierarchy yourself.
    ///
    @MainActor
    @preconcurrency
    static var nativeAdViewProvider: ((_ container: UIView, _ nativeAd: any DIONativeAdInterface) -> DisplayIONativeAdViewType)?
}
