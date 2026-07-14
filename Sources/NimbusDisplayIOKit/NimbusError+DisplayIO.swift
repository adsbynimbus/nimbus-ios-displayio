//
//  NimbusError+DisplayIO.swift
//  NimbusDisplayIOKit
//  Created on 7/10/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit

extension NimbusError.Domain {
    static let displayio = Self(rawValue: "displayio")
}

extension NimbusError {
    static func displayio(reason: Reason = .failure, stage: Stage, detail: String? = nil) -> NimbusError {
        NimbusError(reason: reason, domain: .displayio, stage: stage, detail: detail)
    }
}
