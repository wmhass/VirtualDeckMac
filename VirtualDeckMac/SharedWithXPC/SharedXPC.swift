//
//  SharedXPCProtocols.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-12.
//

import Foundation

struct XPCMessage: Codable {
    enum MessageType: Codable {
        case crossDeviceMessage(message: CrossDeviceMessage)
        case clientsUpdated(clients: [ConnectedPeer])
        case removePeer(connectedPeer: ConnectedPeer)
    }
    let messageType: MessageType
}


// MARK: - XPCClientProtocol
@objc protocol XPCClientProtocol {
    func handleMessageFromServer(data: Data)
}

extension XPCClientProtocol {
    func handleMessageFromServer(xpcMessage: XPCMessage) throws {
        handleMessageFromServer(data: try JSONEncoder().encode(xpcMessage))
    }
}


// MARK: - XPCServerProtocol
@objc protocol XPCServerProtocol {
    func handleMessageFromClient(data: Data)
}

extension XPCServerProtocol {
    func handleMessageFromClient(xpcMessage: XPCMessage) throws {
        handleMessageFromClient(data: try JSONEncoder().encode(xpcMessage))
    }
}
