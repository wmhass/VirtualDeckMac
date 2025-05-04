//
//  AuthCodeStorage.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-03.
//

import Foundation

extension UserDefaults {
    static var groupDefaults: UserDefaults {
        UserDefaults(suiteName: "group.virtualdeckapp")!
    }
}

struct MacSharedStorage {
    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .groupDefaults) {
        self.userDefaults = userDefaults
    }

    // MARK: - Auth Code
    var pairingCode: String? {
        userDefaults.string(forKey: "pairingCode")
    }

    func store(pairingCode: String?) {
        userDefaults.set(pairingCode, forKey: "pairingCode")
    }

    // MARK: - Trusted Devices
    var trustedDevices: [String] {
        return userDefaults.array(forKey: "trustedDevices") as? [String] ?? []
    }

    func store(trustedDevice: String) {
        var trustedDevices = self.trustedDevices
        trustedDevices.append(trustedDevice)
        userDefaults.set(trustedDevices, forKey: "trustedDevices")
    }
}
