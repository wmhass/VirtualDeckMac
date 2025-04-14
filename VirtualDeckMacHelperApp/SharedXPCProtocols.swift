//
//  SharedXPCProtocols.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-12.
//

import Foundation


@objc protocol MainAppXPCProtocol {
    // Command can be converted to `Command`
    func handleNewCommand(clientId: String, command: Data)
    func clientsUpdated(clients: [String])
    func handshake()
}

@objc protocol HelperAppXPCProtocol {
    func sendCommand(_ command: String)
}
