//
//  AdvertiserDiscoveryInfo.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-06-01.
//
import Foundation

struct AdvertiserDiscoveryInfo: Codable {
    let readableName: String?
    let advertiserVersion: String?

    init(readableName: String, advertiserVersion: String?) {
        self.readableName = readableName
        self.advertiserVersion = advertiserVersion
    }

    init(from dictionary: [String: String]?) {
        self.readableName = dictionary?["readableName"]
        self.advertiserVersion = dictionary?["advertiserVersion"]
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


extension String {
    func compareVersion(to other: String) -> ComparisonResult {
        let parts1 = self.split(separator: ".").compactMap { Int($0) }
        let parts2 = other.split(separator: ".").compactMap { Int($0) }

        let maxCount = max(parts1.count, parts2.count)

        for i in 0..<maxCount {
            let v1 = i < parts1.count ? parts1[i] : 0
            let v2 = i < parts2.count ? parts2[i] : 0
            if v1 < v2 { return .orderedAscending }
            if v1 > v2 { return .orderedDescending }
        }

        return .orderedSame
    }

    func isVersion(higherThan other: String) -> Bool {
        return compareVersion(to: other) == .orderedDescending
    }
}
