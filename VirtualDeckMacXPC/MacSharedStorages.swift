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

struct AuthCodeStorage {
    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .groupDefaults) {
        self.userDefaults = userDefaults
    }

    func store(_ authCode: String) {
        userDefaults.set(authCode, forKey: "authCode")
    }

    var authCode: String? {
        userDefaults.string(forKey: "authCode")
    }
}

struct TrustedDevicesStorage {
    let userDefaults: UserDefaults
    init(userDefaults: UserDefaults = .groupDefaults) {
        self.userDefaults = userDefaults
    }

    var trustedDevices: [String] {
        return userDefaults.array(forKey: "trustedDevices") as? [String] ?? []
    }

    func trustDevice(id: String) {
        var trustedDevices = self.trustedDevices
        trustedDevices.append(id)
        userDefaults.set(trustedDevices, forKey: "trustedDevices")
    }

    func isDeviceTrusted(id: String) -> Bool {
        return trustedDevices.contains(id)
    }
}
