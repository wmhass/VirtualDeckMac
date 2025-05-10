//
//  AppDelegate.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-15.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private(set) var xpcServer: XPCServerProtocol?
    var connection: NSXPCConnection?
    let commandHandler = CommandHandler()
    let storage = MacSharedStorage()

    @Published var connectedPeers: [ConnectedPeer] = []
    @Published @MainActor var isPairing: Bool = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ AppDelegate: did finish launching")
        connectToXPC()
    }

    func connectToXPC() {
        connection = NSXPCConnection(serviceName: "com.williamhass.VirtualDeckMacXPC")
        connection?.remoteObjectInterface = NSXPCInterface(with: XPCServerProtocol.self)
        connection?.exportedInterface = NSXPCInterface(with: XPCClientProtocol.self)
        connection?.exportedObject = self
        connection?.invalidationHandler = {
            print("❌ XPC connection invalidated")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.connectToXPC()
            }
        }

        connection?.interruptionHandler = {
            print("⚠️ XPC connection interrupted")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.connectToXPC()
            }
        }
        connection?.resume()
        xpcServer = connection?.remoteObjectProxyWithErrorHandler { error in
            print("❌ XPC proxy error: \(error.localizedDescription)")
        } as? XPCServerProtocol

        print("XPC Server: \(String(describing: xpcServer))")

        publishCommands()
    }

    func prepareForPairing() {
        let code = Int.random(in: 1000...9999)
        storage.store(pairingCode: String(code))
        Task { @MainActor in
            isPairing = true
        }
    }

    func cancelPairing() {
        storage.store(pairingCode: nil)
        Task { @MainActor in
            isPairing = false
        }
    }

    func removeConnectedPeer(_ connectedPeer: ConnectedPeer) {
        try? xpcServer?.handleMessageFromClient(xpcMessage: XPCMessage(
            messageType: .removePeer(connectedPeer: connectedPeer)
        ))
    }
}

extension AppDelegate: XPCClientProtocol {

    func handleMessageFromServer(data: Data) {
        do {
            let xpcMessage = try JSONDecoder().decode(XPCMessage.self, from: data)
            switch xpcMessage.messageType {
                case .crossDeviceMessage(message: let crossDeviceMessage):
                    switch crossDeviceMessage.messageType {
                        case .command(let command):
                            commandHandler.handleCommand(command: command.command)
                        case .commandsUpdate:
                            break;
                        case .textMessage:
                            break;
                    }
                case .clientsUpdated(clients: let clients):
                    Task { @MainActor in
                        if isPairing {
                            isPairing = false
                        }
                    }
                    print("Clients updated: \(String(describing: clients))")
                    DispatchQueue.main.async {
                        self.connectedPeers = clients
                    }
                    publishCommands()
                case .removePeer(connectedPeer: let connectedPeer):
                    print("Only server supports removing clients")
            }
        } catch {
            print("Error decoding XPCMessage from the server: \(error)")
        }

    }

    func publishCommands() {
        let commands: [IdentifiableCommand] = [
            IdentifiableCommand(
                id: "1",
                imageName: "command_1",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 6, height: 1),
                    position: .topLeft
                ))),
            IdentifiableCommand(
                id: "2",
                imageName: "command_2",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 3, height: 1),
                    position: .topLeft
                ))),
            IdentifiableCommand(
                id: "3",
                imageName: "command_3",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 3, height: 1),
                    position: .rightEdgeCenterOfScreen
                ))),
            IdentifiableCommand(
                id: "4",
                imageName: "command_4",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 2, height: 1),
                    position: .rightEdgeCenterOfScreen
                ))),
            IdentifiableCommand(
                id: "5",
                imageName: "command_5",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 2, height: 1),
                    position: .leftEdgeCenterOfScreen
                ))),
            IdentifiableCommand(
                id: "6",
                imageName: "command_6",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 3, height: 1),
                    position: .leftEdgeCenterOfScreen
                ))),
            IdentifiableCommand(
                id: "7",
                imageName: "command_7",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 3, height: 1),
                    position: .topRight
                ))),
            IdentifiableCommand(
                id: "8",
                imageName: "command_8",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 6, height: 1),
                    position: .topRight
                ))),
            IdentifiableCommand(
                id: "9",
                imageName: "command_9",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 3, height: 1),
                    position: .centered
                ))),
            IdentifiableCommand(
                id: "10",
                imageName: "command_10",
                command: Command(commandType: .screenResize(
                    resizeType: .toFraction(width: 2, height: 1),
                    position: .centered
                )))
        ]
        let crossDeviceMessage = CrossDeviceMessage(messageType: .commandsUpdate(commands: commands))
        try? xpcServer?.handleMessageFromClient(xpcMessage: XPCMessage(
            messageType: .crossDeviceMessage(message: crossDeviceMessage)
        ))
    }
}
