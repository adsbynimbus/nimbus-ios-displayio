//
//  DisplayIONativeAdViewType.swift
//  NimbusDisplayIOKit
//  Created on 7/10/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import DIOSDK

/**
 A `UIView` subclass capable of presenting DisplayIO native ads.
 
 Pass an instance conforming to this protocol to `DisplayIOExtension.nativeAdViewProvider`
 to render a native DisplayIO ad.
 */
public protocol DisplayIONativeAdViewType: UIView {
    /// DIONativeMediaView where the DisplayIO SDK mounts the main media (static
    /// image or video player).
    var mediaSlot: DIONativeMediaView { get }
    
    /// Optional DIONativeMediaView for the advertiser icon. Pass
    /// nil if your layout has no icon
    var iconSlot: DIONativeMediaView? { get }
    
    /// Headline of the native ad
    var headlineLabel: UILabel? { get }
    
    /// Action button of the native add
    var ctaButton: UIButton? { get }
}
