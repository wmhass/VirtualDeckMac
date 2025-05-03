//
//  MPCBrowser.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-03.
//
import MultipeerConnectivity

class MPCBrowser: NSObject {
    private let serviceType = "vmchat"
    private let myPeerID: MCPeerID
    private let session: MCSession
    private let browser: MCNearbyServiceBrowser
    var sessionDelegateBridge: MCSessionDelegate?

    override init() {
        myPeerID = PeerIdStorage.peerId ?? PeerIdStorage.generateAndStorePeerId(prefix: "VisionPro")
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        super.init()
        session.delegate = self
        browser.delegate = self
        browser.startBrowsingForPeers()
    }

    func sendCrossDeviceMessage(_ crossDeviceMessage: CrossDeviceMessage) throws {
        let data = try JSONEncoder().encode(crossDeviceMessage)
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}


extension MPCBrowser: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID)")
        let handshake = Handkshake(authCode: "123456")
        browser.invitePeer(
            peerID,
            to: session,
            withContext: try? JSONEncoder().encode(handshake),
            timeout: 30
        )
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }
}

extension MPCBrowser: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Peer \(peerID) state changed to \(state)")
        sessionDelegateBridge?.session(session, peer: peerID, didChange: state)
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        sessionDelegateBridge?.session(session, didReceive: data, fromPeer: peerID)
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName: String, fromPeer: MCPeerID) {
        sessionDelegateBridge?.session(session, didReceive: stream, withName: withName, fromPeer: fromPeer)
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, with: Progress) {
        sessionDelegateBridge?.session(session, didStartReceivingResourceWithName: didStartReceivingResourceWithName, fromPeer: fromPeer, with: with)
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, at: URL?, withError: Error?) {
        sessionDelegateBridge?.session(session, didFinishReceivingResourceWithName: didFinishReceivingResourceWithName, fromPeer: fromPeer, at: at, withError: withError)
    }
}
