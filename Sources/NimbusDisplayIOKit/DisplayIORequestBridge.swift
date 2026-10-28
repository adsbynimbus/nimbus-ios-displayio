//
//  DisplayIORequestBridge.swift
//  NimbusDisplayIOKit
//  Created on 7/10/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import DIOSDK
import NimbusKit

protocol DisplayIORequestBridgeType: Sendable {
    func bidToken() throws -> String
}

final class DisplayIORequestBridge: DisplayIORequestBridgeType {
    
    func bidToken() throws -> String {
        guard let token = DIOController.sharedInstance().getToken(), !token.isEmpty else {
            throw NimbusError.displayio(stage: .request, detail: "Couldn't fetch bid token")
        }
        
        return token
    }
}
