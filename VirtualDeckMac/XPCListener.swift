//
//  XPCListener.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-13.
//
import Foundation
import AppKit

extension XPCListener: MainAppXPCProtocol {
    func handleNewCommand(clientId: String, command: Data) {
        print("XPC Main App Received a message")
        do {
            let decoder = JSONDecoder()
            let decodedCommand = try decoder.decode(Command.self, from: command)
            print("Decoded command: \(decodedCommand)")
            // You can now handle the decoded command, for example:
            commandHandler.handleCommand(command: decodedCommand)
            DispatchQueue.main.async {
                self.messages.append("Received: \(String(describing: decodedCommand))")
            }
        } catch {
            print("Failed to decode command: \(error)")
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
