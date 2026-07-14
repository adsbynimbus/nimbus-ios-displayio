//
//  DisplayIORequestInterceptor.swift
//  NimbusDisplayIOKit
//  Created on 7/10/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit
import DIOSDK

final class DisplayIORequestInterceptor {
    
    /// Bridge that communicates with DisplayIO SDK
    private let bridge: DisplayIORequestBridgeType
    
    init(bridge: DisplayIORequestBridgeType = DisplayIORequestBridge()) {
        self.bridge = bridge
    }
}

extension DisplayIORequestInterceptor: NimbusRequest.Interceptor {
    public func modifyRequest(request: NimbusRequest) async throws -> [NimbusRequest.Delta] {
        let bidToken = try bridge.bidToken()
        try Task.checkCancellation()
        
        return [.init(target: .user, key: "displayio_buyer_uid", value: bidToken)]
    }
}
