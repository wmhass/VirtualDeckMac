//
//  MPCBrowserManager.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-04.
//

import MultipeerConnectivity
class MPCBrowserManager: NSObject, ObservableObject {

    let browser = MPCBrowser()
    @Published @MainActor var commands: [IdentifiableCommand] = []
    @Published @MainActor var connectedPeers: [String] = []
    @Published @MainActor private(set) var hasAdvertiserSetup: Bool = false
    @Published @MainActor private(set) var peerIdDiscoveryInfo: [MCPeerID: [String: String]] = [:]
    private let storage = VisionProStorage()

    override init() {
        super.init()
        browser.sessionDelegateBridge = self
        browser.browserDelegateBridge = self
        Task { @MainActor in
            hasAdvertiserSetup = storage.advertiserId != nil
        }
    }

    func pair(pairingCode: String) {
        Task { @MainActor in
            let firstPeer = peerIdDiscoveryInfo.keys.first!
            browser.connect(to: firstPeer, pairingCode: pairingCode)
        }
    }

    func repair() {
        storage.store(advertiserId: nil)
        Task { @MainActor in
            hasAdvertiserSetup = storage.advertiserId != nil
        }
    }
}

extension MPCBrowserManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            storage.store(advertiserId: peerID.displayName)
            Task { @MainActor in
                hasAdvertiserSetup = true
            }
        }
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers.compactMap { peerId in
                self.peerIdDiscoveryInfo[peerId]?["readableName"]
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let crossDeviceMessage = try! JSONDecoder().decode(CrossDeviceMessage.self, from: data)
        switch crossDeviceMessage.messageType {
            case .commandsUpdate(commands: let commands):
                DispatchQueue.main.async {
                    self.commands = commands
                }
            case .command, .textMessage:
                print("Browser does not support those commands")
                break;
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
    }
}

extension MPCBrowserManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        print("Did find peer: \(peerID.displayName)")
        Task { @MainActor in
            peerIdDiscoveryInfo[peerID] = info ?? [:]
        }
        if peerID.displayName == storage.advertiserId {
            self.browser.connect(to: peerID, pairingCode: nil)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }
}
