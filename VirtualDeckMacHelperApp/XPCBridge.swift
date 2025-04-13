//
//  XPCBridge.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-13.
//

import Foundation
import AppKit
import MultipeerConnectivity

extension XPCBridge: HelperAppXPCProtocol {
    func sendCommand(_ command: String) {
        print("Helper App received a message")
        multiPeerManager.send(command)
    }
}

extension XPCBridge: MultipeerManagerDelegate {
    func handleCommand(_ command: String, clientId: String) {
        mainAppProxy?.handleNewCommand(clientId: clientId, command: command)
    }
    
    func clientsChanged(_ clients: [MCPeerID]) {
        mainAppProxy?.clientsUpdated(clients: clients.map { $0.displayName })
    }
}

class XPCBridge {
    private let multiPeerManager = MultipeerManager()
    private var mainAppProxy: MainAppXPCProtocol?
    private var connection: NSXPCConnection?

    init() {
        multiPeerManager.delegate = self
        connect()
    }

    func connect() {
        connection = NSXPCConnection(machServiceName: "com.williamhass.VirtualDeckMac")
        connection?.remoteObjectInterface = NSXPCInterface(with: MainAppXPCProtocol.self)
        connection?.exportedInterface = NSXPCInterface(with: HelperAppXPCProtocol.self)
        connection?.exportedObject = self
        connection?.invalidationHandler = {
            print("❌ XPC connection invalidated")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.connect()
            }
        }

        connection?.interruptionHandler = {
            print("⚠️ XPC connection interrupted")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.connect()
            }
        }
        connection?.resume()

        mainAppProxy = connection?.remoteObjectProxyWithErrorHandler { error in
            print("❌ XPC proxy error: \(error.localizedDescription)")
        } as? MainAppXPCProtocol
        clientsChanged(multiPeerManager.connectedPeers)
    }
}
