//
//  XPCService.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-05-03.
//

import MultipeerConnectivity

class XPCServer: NSObject {
    private var connectedXpcClient: XPCClientProtocol?
    private let advertiser = MPCAdvertiser()

    override init() {
        super.init()
        advertiser.sessionDelegateBridge = self
    }
}

extension XPCServer: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: (any XPCServerProtocol).self)
        newConnection.exportedObject = self
        newConnection.remoteObjectInterface = NSXPCInterface(with: XPCClientProtocol.self)
        newConnection.invalidationHandler = { [weak self] in
            self?.connectedXpcClient = nil
        }
        newConnection.interruptionHandler = { [weak self] in
            self?.connectedXpcClient = nil
        }
        connectedXpcClient = newConnection.remoteObjectProxy as? XPCClientProtocol
        newConnection.resume()
        return true
    }
}

extension XPCServer: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        do {
            try connectedXpcClient?.handleMessageFromServer(
                xpcMessage: XPCMessage(
                    messageType: .clientsUpdated(clients: session.connectedPeers.map(\.displayName))
                )
            )
        } catch {
            print("Error handling cross device message: \(error)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let crossDeviceMessage = try? JSONDecoder().decode(CrossDeviceMessage.self, from: data) {
            do {
                try connectedXpcClient?.handleMessageFromServer(
                    xpcMessage: XPCMessage(
                        messageType: .crossDeviceMessage(message: crossDeviceMessage)
                    )
                )
            } catch {
                print("Error handling cross device message: \(error)")
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
    }
}

extension XPCServer: XPCServerProtocol {
    func handleMessageFromClient(data: Data) {
        guard let xpcMessage = try? JSONDecoder().decode(XPCMessage.self, from: data) else {
            print("Could not decode JSON for XPC Message on the XPC Server")
            return
        }
        do {
            switch xpcMessage.messageType {
                case .crossDeviceMessage(message: let message):
                    try advertiser.sendCrossDeviceMessage(message)
                case .clientsUpdated:
                    break;
            }
        } catch {
            print("Error handling XPC Message: \(error)")
        }
    }
}
