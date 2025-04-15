//
//  main.swift
//  VirtualDeckMacXPC
//
//  Created by William Hass on 2025-04-15.
//

import Foundation
import MultipeerConnectivity

class ServiceDelegate: NSObject, NSXPCListenerDelegate {

    let multiPeerManager = MultipeerManager()
    var xpcClient: XPCClientProtocol?

    override init() {
        super.init()
        multiPeerManager.delegate = self
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: (any XPCServerProtocol).self)
        newConnection.exportedObject = self
        newConnection.remoteObjectInterface = NSXPCInterface(with: XPCClientProtocol.self)
        newConnection.invalidationHandler = { [weak self] in
             self?.xpcClient = nil
        }
        newConnection.interruptionHandler = { [weak self] in
            self?.xpcClient = nil
        }
        xpcClient = newConnection.remoteObjectProxy as? XPCClientProtocol
        newConnection.resume()
        return true
    }
}

extension ServiceDelegate: XPCServerProtocol {
    func send(data: Data) {
        print("Send message")
        multiPeerManager.send(data: data)
    }
}

extension ServiceDelegate: MultipeerManagerDelegate {
    func handleNewMessage(clientId: String, data: Data) {
        xpcClient?.handleNewMessage(clientId: clientId, data: data)
        print("handleCommand(_ command: String, clientId: String)")
    }

    func clientsChanged(_ clients: [MCPeerID]) {
        print("Clients changed")
        xpcClient?.clientsUpdated(clients: clients.map { $0.displayName })
    }
}

// Create the delegate for the service.
let delegate = ServiceDelegate()

// Set up the one NSXPCListener for this service. It will handle all incoming connections.
let listener = NSXPCListener.service()
listener.delegate = delegate

// Resuming the serviceListener starts this service. This method does not return.
listener.resume()
