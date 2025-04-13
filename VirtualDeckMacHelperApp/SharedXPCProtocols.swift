//
//  SharedXPCProtocols.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-12.
//

import Foundation


@objc protocol MainAppXPCProtocol {
    func handleNewCommand(clientId: String, command: String)
    func clientsUpdated(clients: [String])
    func handshake()
}

@objc protocol HelperAppXPCProtocol {
    func sendCommand(_ command: String)
}
