//
//  MPCAdvertiser.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-03.
//
import MultipeerConnectivity

class MPCAdvertiser: NSObject {
    private let serviceType = "vmchat"
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let macSharedStorage = MacSharedStorage()
    private let peerIdStorage = PeerIdStorage()
    var sessionDelegateBridge: MCSessionDelegate?
    private(set) var peerIdContext: [MCPeerID: MPCContext] = [:]

    override init() {
        UserDefaults.standard.set(nil, forKey: "peerId")
        let prefix = "Mac"
        let peerIdString = peerIdStorage.peerId ?? peerIdStorage.generateAndStorePeerId(prefix: prefix)
        let peerId = MCPeerID(displayName: peerIdString)
        session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerId,
            discoveryInfo: ["readableName": Host.current().localizedName ?? "Mac"],
            serviceType: serviceType
        )
        super.init()
        session.delegate = self
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }

    func sendCrossDeviceMessage(_ crossDeviceMessage: CrossDeviceMessage) throws {
        let data = try JSONEncoder().encode(crossDeviceMessage)
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}

extension MPCAdvertiser: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard let context, let mpcContext = try? JSONDecoder().decode(MPCContext.self, from: context) else {
            print("🚫 Rejecting \(peerID.displayName)")
            invitationHandler(false, session)
            return
        }
        if macSharedStorage.trustedDevices.contains(peerID.displayName) {
            print("🔐 Already trusted device invited: \(peerID.displayName)")
            peerIdContext[peerID] = mpcContext
            invitationHandler(true, session)
        } else if let handshake = mpcContext.handshake,
                  handshake.authCode == macSharedStorage.authCode {
            macSharedStorage.store(trustedDevice: peerID.displayName)
            print("🔐 Trusted device invited: \(peerID.displayName)")
            peerIdContext[peerID] = mpcContext
            invitationHandler(true, session)
        } else {
            print("🚫 Rejecting \(peerID.displayName)")
            invitationHandler(false, session)
        }
    }
}

extension MPCAdvertiser: MCSessionDelegate {
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
