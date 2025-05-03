//
//  MultipeerManager.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-13.
//

import Foundation
import MultipeerConnectivity

struct Handkshake: Codable {
    let authCode: String
}

struct PeerIdStorage {
    static private let key: String = "peerId"
    static var peerId: MCPeerID? {
        guard let peerIdString = UserDefaults.standard.string(forKey: Self.key) else {
            return nil
        }
        return MCPeerID(displayName: peerIdString)
    }
    
    static func generateAndStorePeerId(prefix: String) -> MCPeerID {
        let peerIdString = prefix + "_" + UUID().uuidString
        UserDefaults.standard.set(peerId, forKey: Self.key)
        return MCPeerID(displayName: peerIdString)
    }
}
