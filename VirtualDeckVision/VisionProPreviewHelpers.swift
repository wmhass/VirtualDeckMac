//
//  VisionProPreviewHelpers.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-10.
//

class VisionProStoragePreview: VisionProStorageProtocol {
    var advertiserId: String? = "12345"

    func store(advertiserId: String?) {
        self.advertiserId = advertiserId
    }
}

import MultipeerConnectivity
class MPCBroswerPreview: MPCBrowserProtocol {
    var sessionDelegate: MCSessionDelegate?
    var browserDelegate: MCNearbyServiceBrowserDelegate?

    func setDelegates(sessionDelegate: MCSessionDelegate, browserDelegate: MCNearbyServiceBrowserDelegate) {
        self.browserDelegate = browserDelegate
        self.sessionDelegate = sessionDelegate
    }

    func sendCrossDeviceMessage(_ crossDeviceMessage: CrossDeviceMessage) throws {
    }

    func connect(to peerID: MCPeerID, pairingCode: String?) {
    }
}
