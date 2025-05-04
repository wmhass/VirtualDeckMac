//
//  MPCContext.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-03.
//

import Foundation
import MultipeerConnectivity

struct Handshake: Codable {
    let authCode: String
}

struct MPCContext: Codable {
    let handshake: Handshake?
    let deviceReadableName: String
}
