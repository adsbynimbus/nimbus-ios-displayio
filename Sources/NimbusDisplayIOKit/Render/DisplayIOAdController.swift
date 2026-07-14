//
//  DisplayIOAdController.swift
//  NimbusDisplayIOKit
//  Created on 7/10/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusKit
import DIOSDK

// Internal: Do NOT implement delegate conformance as separate extensions as the methods will not be found in runtime when built as a static library
final class DisplayIOAdController: AdController {
    
    var dioAd: DIOAd?
    
    override class func setup(
        response: NimbusResponse,
        container: UIView,
        adPresentingViewController: UIViewController?
    ) -> AdController {
        let adController = Self.init(
            response: response,
            isBlocking: false,
            isRewarded: false,
            container: container,
            adPresentingViewController: adPresentingViewController
        )
        
        return adController
    }
    
    override class func setupBlocking(
        response: NimbusResponse,
        isRewarded: Bool,
        adPresentingViewController: UIViewController,
    ) -> AdController {
        let adController = Self.init(
            response: response,
            isBlocking: true,
            isRewarded: isRewarded,
            container: nil,
            adPresentingViewController: adPresentingViewController
        )
        
        return adController
    }
    
    override func load() {
        guard let placementId = response.bid.ext?.omp?.buyerPlacementId else {
            sendNimbusError(.displayio(reason: .invalidState, stage: .render, detail: "Placement id is missing"))
            return
        }
        
        let placement = DIOController.sharedInstance().placement(withId: placementId)
        placement.loadAd(fromORTB: response.bid.adm) { [weak self] dioAd in
            self?.readyAndPresent(ad: dioAd)
        } noAdHandler: { [weak self] error in
            self?.sendNimbusError(.displayio(stage: .render, detail: error.localizedDescription))
        }
    }
    
    func presentIfNeeded() {
        guard started, adState == .ready else { return }
        guard let dioAd else {
            sendNimbusError(.displayio(reason: .invalidState, stage: .render, detail: "Cannot present ad, DIOAd is nil"))
            return
        }
        
        adState = .resumed
        
        switch adRenderType {
        case .banner:
            dioAd.adEventHandler = { [weak self] event in
                self?.onDisplayIO(event: event)
            }
            
            let dioAdView = dioAd.view()
            dioAdView.translatesAutoresizingMaskIntoConstraints = true
            dioAdView.autoresizesSubviews = true
            dioAdView.autoresizingMask = []
            dioAdView.frame = CGRect(x: 0, y: 0, width: response.bid.w ?? 0, height: response.bid.h ?? 0)
            adView.addSubview(dioAdView)
            
            // deactivate size constraints that are covered by autoresizing mask constraints for flexible layout
            let sdkSizeConstraints = dioAdView.constraints.filter { constraint in
                String(describing: type(of: constraint)) != "NSAutoresizingMaskLayoutConstraint"
                && (constraint.firstItem === dioAdView && constraint.secondItem == nil)
                && (constraint.firstAttribute == .width || constraint.firstAttribute == .height)
            }
            NSLayoutConstraint.deactivate(sdkSizeConstraints)

        case .native:
            guard let native = dioAd as? DIONativeAdInterface else {
                sendNimbusError(.displayio(reason: .configuration, stage: .render, detail: "Native ad is not of type DIONativeAdInterface"))
                return
            }
            
            guard let nativeAdViewProvider = DisplayIOExtension.nativeAdViewProvider else {
                sendNimbusError(.displayio(reason: .configuration, stage: .render, detail: "DisplayIOExtension.nativeAdViewProvider must be set to render native ads"))
                return
            }
            
            let nativeView = nativeAdViewProvider(adView, native)
            nativeView.translatesAutoresizingMaskIntoConstraints = false
            
            adView.addSubview(nativeView)
            
            NSLayoutConstraint.activate([
                nativeView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
                nativeView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
                nativeView.topAnchor.constraint(equalTo: adView.topAnchor),
                nativeView.bottomAnchor.constraint(equalTo: adView.bottomAnchor)
            ])
            
            dioAd.adEventHandler = { [weak self] event in
                self?.onDisplayIO(event: event)
            }
            
            native.registerView(
                forInteraction: adView,
                mediaSlot: nativeView.mediaSlot,
                iconSlot: nativeView.iconSlot,
                headlineLabel: nativeView.headlineLabel,
                ctaButton: nativeView.ctaButton
            )
        case .interstitial, .rewarded:
            guard let adPresentingViewController else {
                sendNimbusError(.displayio(reason: .invalidState, stage: .render, detail: "Cannot present fullscreen ad, adPresentingViewController is nil"))
                return
            }
            
            dioAd.show(from: adPresentingViewController) { [weak self] event in
                self?.onDisplayIO(event: event)
            }
        }
    }
    
    func onDisplayIO(event: DIOAdEvent) {
        switch event {
        case .onShown:
            sendNimbusEvent(.impression)
        case .onFailedToShow:
            sendNimbusError(.displayio(stage: .render, detail: "Failed to show ad"))
        case .onClicked:
            sendNimbusEvent(.clicked)
        case .onClosed:
            destroy()
        case .onAdCompleted:
            if adRenderType == .rewarded {
                sendNimbusEvent(.completed)
                sendNimbusEvent(.rewardEarned)
            }
        default:
            break
        }
    }
    
    override func onStart() {
        presentIfNeeded()
    }
    
    override func onDestroy() {
        dioAd = nil
    }
    
    private func readyAndPresent(ad: DIOAd) {
        adState = .ready
        sendNimbusEvent(.loaded)
        dioAd = ad
        presentIfNeeded()
    }
}
