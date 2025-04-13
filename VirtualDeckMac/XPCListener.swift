//
//  XPCListener.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-13.
//
import Foundation
import AppKit

extension XPCListener: MainAppXPCProtocol {
    func handleNewCommand(clientId: String, command: String) {
        print("XPC Main App Received a message")
        commandHandler.handleCommand(command: command)
        DispatchQueue.main.async {
            self.messages.append("\(clientId): \(command)")
        }
    }

    func clientsUpdated(clients: [String]) {
        DispatchQueue.main.async {
            self.connectedClients = clients
        }
    }

    func handshake() {
        print("🤝 New connection handshake")
    }
}

extension XPCListener: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        print("shouldAcceptNewConnection")
        connection.exportedInterface = NSXPCInterface(with: MainAppXPCProtocol.self)
        connection.exportedObject = self

        // Setup reverse communication
        connection.remoteObjectInterface = NSXPCInterface(with: HelperAppXPCProtocol.self)
        connection.invalidationHandler = { [weak self] in
            self?.helperAppProxy = nil
        }

        connection.interruptionHandler = { [weak self] in
            self?.helperAppProxy = nil
        }

        helperAppProxy = connection.remoteObjectProxy as? HelperAppXPCProtocol

        connection.resume()

        return true
    }
}

class XPCListener: NSObject, ObservableObject {
    let commandHandler = MultiPeerCommandHandler()
    let listener = NSXPCListener(machServiceName: "com.williamhass.VirtualDeckMac")
    var helperAppProxy: HelperAppXPCProtocol?

    @Published var connectedClients: [String] = []
    @Published var messages: [String] = []

    override init() {
        super.init()
        listener.delegate = self
    }

    func startListening() {
        listener.resume()
    }

    func send(message: String) {
        helperAppProxy?.sendCommand(message)
    }
}
