//
//  VisionProStorage.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-04.
//

import Foundation

struct VisionProStorage {
    private let peerInfoKey: String = "peerInfoKey"
    private let pairingCodeKey: String = "pairingCodeKey"
    private let userDefaults: UserDefaults = .standard
}

extension VisionProStorage: VisionProStorageProtocol {
    var peerInfo: PeerInfo? {
        guard let peerInfoData = userDefaults.data(forKey: peerInfoKey) else {
            return nil
        }
        return try? JSONDecoder().decode(PeerInfo.self, from: peerInfoData)
    }

    var pairingCode: String? {
        return userDefaults.string(forKey: pairingCodeKey)
    }

    func store(pairingCode: String?) {
        userDefaults.set(pairingCode, forKey: pairingCodeKey)
    }

    func store(peerInfo: PeerInfo?) {
        if let peerInfo, let jsonData = try? JSONEncoder().encode(peerInfo) {
            userDefaults.set(jsonData, forKey: peerInfoKey)
        } else {
            userDefaults.set(nil, forKey: peerInfoKey)
        }
    }
}
