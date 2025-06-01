//
//  MPCBrowserManager.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-04.
//

protocol MPCBrowserProtocol: AnyObject {
    func connect(to peerID: MCPeerID, pairingCode: String)
    func sendCrossDeviceMessage(_ crossDeviceMessage: CrossDeviceMessage) throws
    func setDelegates(sessionDelegate: MCSessionDelegate, browserDelegate: MCNearbyServiceBrowserDelegate)
    func startBrowsing()
}

protocol VisionProStorageProtocol {
    var peerInfo: PeerInfo? { get }
    var pairingCode: String? { get }
    func store(peerInfo: PeerInfo?)
    func store(pairingCode: String?)
}

struct PeerInfo: Hashable, Identifiable, Codable {
    var id: String { peerId.displayName }
    let readableName: String
    let peerId: MCPeerID

    enum CodingKeys: String, CodingKey {
        case readableName
        case peerId
    }

    init(readableName: String, peerId: MCPeerID) {
        self.readableName = readableName
        self.peerId = peerId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.readableName = try container.decode(String.self, forKey: .readableName)
        let peerIdData = try container.decode(Data.self, forKey: .peerId)
        guard let peerId = try NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: peerIdData) else {
            throw DecodingError.dataCorruptedError(forKey: .peerId, in: container, debugDescription: "Unable to decode MCPeerID")
        }
        self.peerId = peerId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(readableName, forKey: .readableName)
        let peerIdData = try NSKeyedArchiver.archivedData(withRootObject: peerId, requiringSecureCoding: false)
        try container.encode(peerIdData, forKey: .peerId)
    }
}

import MultipeerConnectivity
class MPCBrowserManager: NSObject, ObservableObject {

    enum BrowserState {
        case didntSetup
        case didSetupButPeerIsNotAvailable
        case didSetupAndPeerIsConnected
    }

    enum ConnectionState {
        case notConnected
        case connecting
        case connected
    }

    private let storage: VisionProStorageProtocol
    private let browser: MPCBrowserProtocol

    var savedPeerInfo: PeerInfo? {
        storage.peerInfo
    }
    @Published @MainActor var commands: [IdentifiableCommand] = []
    @Published @MainActor var connectedPeer: PeerInfo?
    @Published @MainActor private(set) var availablePeers: [PeerInfo] = []
    @Published @MainActor private(set) var browserState: BrowserState = .didntSetup
    @Published @MainActor private(set) var errorPairing: String?
    @Published @MainActor private(set) var connectionState: ConnectionState = .notConnected
    private var attemptedPairingCode: String?
    private var attemptingToConnectToId: MCPeerID?

    @available(*, unavailable, message: "Use init(browser:storage:) instead.")
    override init() {
        fatalError("Unavailable initializer was called")
    }

    init(browser: MPCBrowserProtocol, storage: VisionProStorageProtocol) {
        self.browser = browser
        self.storage = storage
        super.init()
        browser.setDelegates(sessionDelegate: self, browserDelegate: self)
        browser.startBrowsing()
        updateState()
    }

    func updateState() {
        Task { @MainActor in
            // We have `peerInfo` in the `storage`, but it is not connected
            if storage.peerInfo != nil, connectedPeer == nil {
                browserState = .didSetupButPeerIsNotAvailable
                // We have `peerInfo` in the `storage` and `peer` is `connected`
            } else if let peerInfo = storage.peerInfo, let connectedPeer, connectedPeer.peerId == peerInfo.peerId {
                browserState = .didSetupAndPeerIsConnected
            } else {
                browserState = .didntSetup
            }
        }
    }

    func pair(pairingCode: String, peerId: MCPeerID) {
        Task { @MainActor in
            print("**Attempt to connect to \(peerId.displayName) / Available peers: \(availablePeers)")
        }
        attemptedPairingCode = pairingCode
        attemptingToConnectToId = peerId
        browser.connect(to: peerId, pairingCode: pairingCode)
    }

    func repair() {
        storage.store(pairingCode: nil)
        storage.store(peerInfo: nil)
        updateState()
    }

    func sendCrossDeviceMessage(_ message: CrossDeviceMessage) throws {
        try browser.sendCrossDeviceMessage(message)
    }
}

extension MPCBrowserManager: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("State changed: \(state)")
        Task { @MainActor in

            switch state {
                case .connected:
                    connectionState = .connected
                case .connecting:
                    connectionState = .connecting
                case .notConnected:
                    connectionState = .notConnected
                @unknown default:
                    connectionState = .notConnected
            }

            if state == .notConnected, peerID.displayName == attemptingToConnectToId?.displayName {
                errorPairing = "Failed to connect to \(availablePeers.first(where: { $0.peerId == peerID })?.readableName ?? peerID.displayName)"
            } else if state == .connected {
                errorPairing = nil
                attemptingToConnectToId = nil
            } else if state == .connecting {
                errorPairing = nil
            }
        }
        Task { @MainActor in
            if state == .connected, let peer = availablePeers.first(where: { $0.peerId == peerID }) {
                if let attemptedPairingCode {
                    storage.store(pairingCode: attemptedPairingCode)
                }
                connectedPeer = peer
                storage.store(peerInfo: peer)
            } else {
                connectedPeer = nil
            }
            updateState()
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

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {}
}

extension MPCBrowserManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        print("Did find peer: \(peerID.displayName) // stored peer: \(String(describing: storage.peerInfo))")
        Task { @MainActor in
            if let readableName = info?["readableName"] {
                print("Peer with readable name:\(readableName) found")
                var newPeers = availablePeers
                newPeers.removeAll(where: { $0.peerId == peerID })
                newPeers.append(PeerInfo(
                    readableName: readableName,
                    peerId: peerID
                ))
                availablePeers = newPeers
            }
            print("Stored peerInfo: \(String(describing: storage.peerInfo))")
            print("Stored pairingCode: \(String(describing: storage.pairingCode))")
            if peerID.displayName == storage.peerInfo?.peerId.displayName,
                let pairingCode = storage.pairingCode {
                print("- Peer id is stored. attempt to connect")
                self.browser.connect(to: peerID, pairingCode: pairingCode)
                updateState()
            } else {
                updateState()
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            availablePeers.removeAll(where: { $0.peerId == peerID })
            updateState()
            print("--Lost peer \(peerID.displayName). Available peers: \(availablePeers)")
        }
    }
}
