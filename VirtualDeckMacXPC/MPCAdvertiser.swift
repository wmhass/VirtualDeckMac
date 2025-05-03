//
//  MPCAdvertiser.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-03.
//
import MultipeerConnectivity

class MPCAdvertiser: NSObject {
    private let serviceType = "vmchat"
    private let myPeerID: MCPeerID
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let authCodeStorage: AuthCodeStorage = AuthCodeStorage()
    private let trustedDevicesStorage: TrustedDevicesStorage = TrustedDevicesStorage()
    var sessionDelegateBridge: MCSessionDelegate?

    override init() {
        myPeerID = PeerIdStorage.peerId ?? PeerIdStorage.generateAndStorePeerId(prefix: "Mac")
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
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
        if trustedDevicesStorage.isDeviceTrusted(id: peerID.displayName) {
            print("🔐 Already trusted device invited: \(peerID.displayName)")
            invitationHandler(true, session)
        } else if let context,
                  let handshake = try? JSONDecoder().decode(Handkshake.self, from: context),
                  handshake.authCode == authCodeStorage.authCode {
            trustedDevicesStorage.trustDevice(id: peerID.displayName)
            print("🔐 Trusted device invited: \(peerID.displayName)")
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
