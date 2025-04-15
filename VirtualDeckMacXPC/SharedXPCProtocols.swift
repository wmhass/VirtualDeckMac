//
//  SharedXPCProtocols.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-12.
//

import Foundation

@objc protocol XPCClientProtocol {
    // Command can be converted to `CrossDeviceMessage`
    func handleNewMessage(clientId: String, data: Data)
    func clientsUpdated(clients: [String])
}

@objc protocol XPCServerProtocol {
    func send(data: Data)
}
