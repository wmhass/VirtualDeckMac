//
//  MPCBrowser.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-03.
//
import MultipeerConnectivity

class MPCBrowser: NSObject {
    private let serviceType = "vmchat"
    private let session: MCSession
    private let nearbyServiceBrowser: MCNearbyServiceBrowser
    private let peerIdStorage = PeerIdStorage()

    weak private var sessionDelegateBridge: MCSessionDelegate?
    weak private var browserDelegateBridge: MCNearbyServiceBrowserDelegate?

    override init() {
        let peerIdString = peerIdStorage.peerId ?? peerIdStorage.generateAndStorePeerId(prefix: "VisionPro")
        print("Peer ID: \(peerIdString)")
        let peerId = MCPeerID(displayName: peerIdString)
        session = MCSession(peer: peerId)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        super.init()
        session.delegate = self
        nearbyServiceBrowser.delegate = self
    }

    func startBrowsing() {
        nearbyServiceBrowser.startBrowsingForPeers()
    }
}


extension MPCBrowser: MPCBrowserProtocol {

    func setDelegates(sessionDelegate: MCSessionDelegate, browserDelegate: MCNearbyServiceBrowserDelegate) {
        self.sessionDelegateBridge = sessionDelegate
        self.browserDelegateBridge = browserDelegate
    }

    func sendCrossDeviceMessage(_ crossDeviceMessage: CrossDeviceMessage) throws {
        let data = try JSONEncoder().encode(crossDeviceMessage)
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    func connect(to peerID: MCPeerID, pairingCode: String) {
        let context = MPCContext(
            handshake: Handshake(pairingCode: pairingCode),
            deviceReadableName: UIDevice.current.name
        )
        nearbyServiceBrowser.invitePeer(
            peerID,
            to: session,
            withContext: try? JSONEncoder().encode(context),
            timeout: 30
        )
    }
}

extension MPCBrowser: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        browserDelegateBridge?.browser(browser, foundPeer: peerID, withDiscoveryInfo: info)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        browserDelegateBridge?.browser(browser, lostPeer: peerID)
    }
}

extension MPCBrowser: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)")
        sessionDelegateBridge?.session(session, peer: peerID, didChange: state)
        switch state {
            case .connected:
                nearbyServiceBrowser.stopBrowsingForPeers()
            default:
                nearbyServiceBrowser.startBrowsingForPeers()
        }
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)")
        sessionDelegateBridge?.session(session, didReceive: data, fromPeer: peerID)
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName: String, fromPeer: MCPeerID) {
        print("session(_ session: MCSession, didReceive stream: InputStream, withName: String, fromPeer: MCPeerID)")
        sessionDelegateBridge?.session(session, didReceive: stream, withName: withName, fromPeer: fromPeer)
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, with: Progress) {
        print("session(_ session: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, with: Progress)")
        sessionDelegateBridge?.session(session, didStartReceivingResourceWithName: didStartReceivingResourceWithName, fromPeer: fromPeer, with: with)
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, at: URL?, withError: Error?) {
        print("session(_ session: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, at: URL?, withError: Error?)")
        sessionDelegateBridge?.session(session, didFinishReceivingResourceWithName: didFinishReceivingResourceWithName, fromPeer: fromPeer, at: at, withError: withError)
    }
}
