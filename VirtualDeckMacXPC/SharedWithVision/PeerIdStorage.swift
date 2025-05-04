//
//  PeerIdStorage.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-03.
//

import Foundation

struct PeerIdStorage {
    private let peerIdKey: String = "peerId"
    private let userDefaults: UserDefaults = .standard

    var peerId: String? {
        return UserDefaults.standard.string(forKey: peerIdKey)
    }

    func store(peerId: String) {
        UserDefaults.standard.set(peerId, forKey: peerIdKey)
    }
}

extension PeerIdStorage {
    func generateAndStorePeerId(prefix: String) -> String {
        let peerIdString = prefix + "_" + UUID().uuidString
        store(peerId: peerIdString)
        return peerIdString
    }
}
