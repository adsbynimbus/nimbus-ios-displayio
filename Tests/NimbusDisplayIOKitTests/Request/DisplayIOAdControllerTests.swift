//
//  DisplayIOAdControllerTests.swift
//  NimbusDisplayIOKit
//  Created on 9/24/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Testing
@testable import NimbusDisplayIOKit
@testable import NimbusKit
import UIKit
import DIOSDK

@Suite("DisplayIO AdController tests")
@MainActor
struct DisplayIOAdControllerTests {
    @Test func bannerAdEventsGetFired() {
        let container = UIView()
        let adController = DisplayIOAdController(
            response: .init(id: "", bid: .init(mtype: .static, adm: "", price: 0, ext: .init())),
            isBlocking: false,
            isRewarded: false,
            container: container,
            adPresentingViewController: nil
        )
        let delegate = MockDelegate()
        adController.delegate = delegate
        
        let dioAd = MockDIOAd(isInline: true)
        
        adController.dioAd = dioAd
        adController.adState = .ready
        
        
        #expect(adController.adView.subviews.isEmpty)
        adController.start()
        #expect(adController.adView.subviews[0] === dioAd.view())
        
        dioAd.adEventHandler(.onShown)
        #expect(delegate.events.last == .impression)
        
        dioAd.adEventHandler(.onClicked)
        #expect(delegate.events.last == .clicked)
        
        // video banner could send completed but should not send rewardEarned
        dioAd.adEventHandler(.onAdCompleted)
        #expect(delegate.events.last == .completed)
        #expect(!delegate.events.contains(.rewardEarned))
        
        dioAd.adEventHandler(.onFailedToShow)
        let error = delegate.lastError
        #expect(error != nil)
        #expect(error!.domain == NimbusError.Domain(rawValue: "displayio"))
        #expect(error!.detail == "Failed to show ad")
        
        #expect(delegate.events.last == .destroyed)
    }
    
    @Test func nativeAdEventsGetFired() {
        let container = UIView()
        let adController = DisplayIOAdController(
            response: .init(id: "", bid: .init(mtype: .native, adm: "", price: 0, ext: .init())),
            isBlocking: false,
            isRewarded: false,
            container: container,
            adPresentingViewController: nil
        )
        let delegate = MockDelegate()
        adController.delegate = delegate
        
        let dioAd = MockNativeDIOAd(isInline: true)
        
        adController.dioAd = dioAd
        adController.adState = .ready
        
        let nativeView = MockNativeAdView()
        
        DisplayIOExtension.nativeAdViewProvider = { container, ad in
            nativeView
        }
        defer { DisplayIOExtension.nativeAdViewProvider = nil }
        
        #expect(adController.adView.subviews.isEmpty)
        adController.start()
        #expect(adController.adView.subviews[0] === nativeView)
        
        dioAd.adEventHandler(.onShown)
        #expect(dioAd.registerViewWasCalled == true)
        #expect(delegate.events.last == .impression)
        
        dioAd.adEventHandler(.onClicked)
        #expect(delegate.events.last == .clicked)
        
        // video banner could send completed but should not send rewardEarned
        dioAd.adEventHandler(.onAdCompleted)
        #expect(delegate.events.last == .completed)
        #expect(!delegate.events.contains(.rewardEarned))
        
        dioAd.adEventHandler(.onFailedToShow)
        let error = delegate.lastError
        #expect(error != nil)
        #expect(error!.domain == NimbusError.Domain(rawValue: "displayio"))
        #expect(error!.detail == "Failed to show ad")
        
        #expect(delegate.events.last == .destroyed)
    }
    
    @Test func interstitialAdEventsGetFired() {
        let container = UIView()
        let controller = UIViewController()
        
        let adController = DisplayIOAdController(
            response: .init(id: "", bid: .init(mtype: .static, adm: "", price: 0, ext: .init())),
            isBlocking: true,
            isRewarded: false,
            container: container,
            adPresentingViewController: controller
        )
        let delegate = MockDelegate()
        adController.delegate = delegate
        
        let dioAd = MockDIOAd(isInline: false)
        
        adController.dioAd = dioAd
        adController.adState = .ready
        
        adController.start()
        dioAd.sendFullscreen(event: .onShown)
        #expect(delegate.events.last == .impression)
        
        dioAd.sendFullscreen(event: .onClicked)
        #expect(delegate.events.last == .clicked)
        
        // video interstitial could send completed but should not send rewardEarned
        dioAd.sendFullscreen(event: .onAdCompleted)
        #expect(delegate.events.last == .completed)
        #expect(!delegate.events.contains(.rewardEarned))
        
        dioAd.sendFullscreen(event: .onClosed)
        #expect(delegate.events.last == .destroyed)
    }
    
    @Test func interstitialAdGetsDestroyedOnError() {
        let container = UIView()
        let controller = UIViewController()
        
        let adController = DisplayIOAdController(
            response: .init(id: "", bid: .init(mtype: .static, adm: "", price: 0, ext: .init())),
            isBlocking: true,
            isRewarded: false,
            container: container,
            adPresentingViewController: controller
        )
        let delegate = MockDelegate()
        adController.delegate = delegate
        
        let dioAd = MockDIOAd(isInline: false)
        
        adController.dioAd = dioAd
        adController.adState = .ready
        adController.start()
        
        #expect(delegate.lastError == nil)
        #expect(delegate.events.isEmpty)
        
        dioAd.sendFullscreen(event: .onFailedToShow)
        
        #expect(delegate.lastError != nil)
        #expect(delegate.events.last == .destroyed)
    }
    
    @Test func rewardedAdEventsGetFired() {
        let container = UIView()
        let controller = UIViewController()
        
        let adController = DisplayIOAdController(
            response: .init(id: "", bid: .init(mtype: .static, adm: "", price: 0, ext: .init())),
            isBlocking: true,
            isRewarded: true,
            container: container,
            adPresentingViewController: controller
        )
        let delegate = MockDelegate()
        adController.delegate = delegate
        
        let dioAd = MockDIOAd(isInline: false)
        
        adController.dioAd = dioAd
        adController.adState = .ready
        
        adController.start()
        dioAd.sendFullscreen(event: .onShown)
        #expect(delegate.events.last == .impression)
        
        dioAd.sendFullscreen(event: .onClicked)
        #expect(delegate.events.last == .clicked)
        
        dioAd.sendFullscreen(event: .onAdCompleted)
        #expect(delegate.events.contains(.completed))
        #expect(delegate.events.last == .rewardEarned)
        
        dioAd.sendFullscreen(event: .onClosed)
        #expect(delegate.events.last == .destroyed)
    }
    
    @Test func rewardedAdGetsDestroyedOnError() {
        let container = UIView()
        let controller = UIViewController()
        
        let adController = DisplayIOAdController(
            response: .init(id: "", bid: .init(mtype: .static, adm: "", price: 0, ext: .init())),
            isBlocking: true,
            isRewarded: true,
            container: container,
            adPresentingViewController: controller
        )
        let delegate = MockDelegate()
        adController.delegate = delegate
        
        let dioAd = MockDIOAd(isInline: false)
        
        adController.dioAd = dioAd
        adController.adState = .ready
        
        adController.start()
        
        #expect(delegate.lastError == nil)
        #expect(delegate.events.isEmpty)
        
        dioAd.sendFullscreen(event: .onFailedToShow)
        
        #expect(delegate.lastError != nil)
        #expect(delegate.events.last == .destroyed)
    }
}

// MARK: - Mocks

class MockNativeDIOAd: MockDIOAd, DIONativeAdInterface {
    var registerViewWasCalled = false
    
    override init(isInline: Bool) {
        super.init(isInline: isInline)
    }
    
    func headline() -> String? { "" }
    
    func body() -> String? { "" }
    
    func callToAction() -> String? { "" }
    
    func advertiser() -> String? { "" }
    
    func price() -> String? { "" }
    
    func privacy() -> String? { "" }
    
    func hasVideoContent() -> Bool { false }
    
    func registerView(forInteraction nativeAdRoot: UIView, mediaSlot: DIONativeMediaView, iconSlot: UIView?, headlineLabel: UILabel?, ctaButton: UIButton?) {
        registerViewWasCalled = true
    }
    
    func unregisterView() {}
    
    func close() {}
    
    func iconUri() -> URL? { URL(string: "https://test.com") }
    
    func iconImage() -> UIImage? { nil }
}

class MockDIOAd: DIOAd {
    var fullscreenAdHandler: ((DIOAdEvent) -> Void)?
    private let isInline: Bool
    private let stubView = UIView()
    
    init(isInline: Bool) {
        self.isInline = isInline
    }
    
    override func view() -> UIView { stubView }
    override func isInlineType() -> Bool { isInline }
    
    func sendFullscreen(event: DIOAdEvent) {
        fullscreenAdHandler?(event)
    }
    
    override func show(from controller: UIViewController, eventHandler: @escaping (DIOAdEvent) -> Void) {
        self.fullscreenAdHandler = eventHandler
    }
}

class MockDelegate: AdController.Delegate {
    var events: [AdEvent] = []
    var lastError: NimbusError?
    
    func didReceiveNimbusEvent(event: NimbusKit.AdEvent) {
        events.append(event)
    }
    
    func didReceiveNimbusError(error: NimbusKit.NimbusError) {
        lastError = error
    }
}

class MockNativeAdView: UIView, DisplayIONativeAdViewType {
    let mediaSlot = DIONativeMediaView()
    
    var iconSlot: DIONativeMediaView?
    var headlineLabel: UILabel?
    var ctaButton: UIButton?
}
