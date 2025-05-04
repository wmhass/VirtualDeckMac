//
//  VisionProStorage.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-04.
//

import Foundation

struct VisionProStorage {
    private let advertiserIdKey: String = "advertiserId"
    private let userDefaults: UserDefaults = .standard

    var advertiserId: String? {
        return userDefaults.string(forKey: advertiserIdKey)
    }

    func store(advertiserId: String?) {
        userDefaults.set(advertiserId, forKey: advertiserIdKey)
    }
}
