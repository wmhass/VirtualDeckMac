//
//  AdvertiserDiscoveryInfo.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-06-01.
//
import Foundation

struct AdvertiserDiscoveryInfo: Codable {
    let readableName: String?

    init(readableName: String) {
        self.readableName = readableName
    }

    init(from dictionary: [String: String]?) {
        self.readableName = dictionary?["readableName"]
    }

    var dictionaryRepresentation: [String: String]? {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject as? [String: String]
        } catch {
            return nil
        }
    }
}
