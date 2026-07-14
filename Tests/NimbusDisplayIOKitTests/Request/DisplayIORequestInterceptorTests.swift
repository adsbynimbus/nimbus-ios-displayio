//
//  DisplayIORequestInterceptorTests.swift
//  NimbusDisplayIOKitTests
//  Created on 7/10/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

@testable import NimbusDisplayIOKit
@testable import NimbusKit
import DIOSDK
import Testing

@Suite("DisplayIO request interceptor tests")
struct DisplayIORequestInterceptorTests {
    
    let interceptor = DisplayIORequestInterceptor(bridge: MockDisplayIORequestBridge())
    
    @Test func bidTokenAndRenderInfoGetsSet() async throws {
        let info = try NimbusRequest(from: await Nimbus.bannerAd(position: "test", size: .banner).adRequest!.request)
        let deltas = try await interceptor.modifyRequest(request: info)
        
        #expect(deltas.count == 1)
        #expect(deltas[0].key == "displayio_buyer_uid")
        #expect(deltas[0].target == .user)
        #expect(deltas[0].value as? String == "unitTestBuyerUID")
    }
    
    @Test func displayioBidTokenGetsInsertedIntoRequest() async throws {
        var request = await Nimbus.rewardedAd(position: "position").adRequest!.request
        request.interceptors = [interceptor]
        
        try await request.modifyRequestWithExtras(
            configuration: Nimbus.configuration,
            vendorId: "",
            appVersion: "1.0.0"
        )
        
        #expect(request.user?.ext?.extras["displayio_buyer_uid"] as? String == "unitTestBuyerUID")
    }
    
    @MainActor private func createNimbusAd(network: String) -> NimbusResponse {
        NimbusResponse(id: "", bid: .init(mtype: .static, adm: "", price: 0, ext: .init(omp: .init(buyer: network, buyerPlacementId: nil))))
    }
}

final class MockDisplayIORequestBridge: DisplayIORequestBridgeType {
    func bidToken() throws -> String {
        "unitTestBuyerUID"
    }
}
