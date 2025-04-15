//
//  MultipeerManager.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-13.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerManagerDelegate: AnyObject {
    func handleNewMessage(clientId: String, data: Data)
    func clientsChanged(_ clients: [MCPeerID])
}

class MultipeerManager: NSObject, ObservableObject {
    private let serviceType = "vmchat"

    private let peerID: MCPeerID
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser

    @Published var messages: [String] = []
    @Published var connectedPeers: [MCPeerID] = []
    weak var delegate: MultipeerManagerDelegate?

    override init() {
#if os(macOS)
        let hostName = Host.current().localizedName ?? "Mac"
#else
        let hostName = UIDevice.current.name
#endif
        peerID = MCPeerID(displayName: hostName)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)

        super.init()

        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        connect()
    }

    func connect() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    func send(data: Data) {
        guard !session.connectedPeers.isEmpty else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        if let dataString = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.messages.append("You: \(String(describing: dataString))")
            }
        }
    }
}

extension MultipeerManager: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("🔄 Peer \(peerID.displayName) changed state to \(state.rawValue)")
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            self.delegate?.clientsChanged(self.connectedPeers)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            print("📩 Received message from \(peerID.displayName): \(message)")
            DispatchQueue.main.async {
                self.messages.append("\(peerID.displayName): \(message)")
            }
        }
        delegate?.handleNewMessage(
            clientId: peerID.displayName,
            data: data
        )
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("📨 Received invitation from \(peerID.displayName)")
        invitationHandler(true, session)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        print("👀 Found peer \(peerID.displayName), sending invitation")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    // Required empty implementations
    func session(_: MCSession, didReceive: InputStream, withName: String, fromPeer: MCPeerID) {
        print("📥 Received input stream \(withName) from \(fromPeer.displayName)")
    }
    func session(_: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, with: Progress) {
        print("⬇️ Started receiving resource \(didStartReceivingResourceWithName) from \(fromPeer.displayName)")
    }
    func session(_: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, at: URL?, withError: Error?) {
        if let error = withError {
            print("❌ Failed to receive resource \(didFinishReceivingResourceWithName) from \(fromPeer.displayName): \(error)")
        } else {
            print("✅ Finished receiving resource \(didFinishReceivingResourceWithName) from \(fromPeer.displayName)")
        }
    }
    func browser(_: MCNearbyServiceBrowser, lostPeer: MCPeerID) {
        print("❌ Lost peer \(lostPeer.displayName)")
    }
}
