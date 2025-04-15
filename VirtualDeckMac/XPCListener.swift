//
//  XPCListener.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-13.
//
import Foundation
import AppKit

extension XPCListener: MainAppXPCProtocol {
    func handleNewMessage(clientId: String, data: Data) {
        let crossDeviceMessage = try! JSONDecoder().decode(CrossDeviceMessage.self, from: data)
        print("XPC Main App Received a message")
        switch crossDeviceMessage.messageType {
            case .command(let command):
                commandHandler.handleCommand(command: command.command)
            case .commandsUpdate(let commands):
                break;
            case .textMessage(text: let text):
                break;
        }
        DispatchQueue.main.async {
            self.messages.append("Received: \(String(describing: crossDeviceMessage))")
        }
    }

    func clientsUpdated(clients: [String]) {
        DispatchQueue.main.async {
            self.connectedClients = clients
        }
        publishCommands()
    }
}

extension XPCListener {
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
        let data = try! JSONEncoder().encode(crossDeviceMessage)
        helperAppProxy?.send(data: data)
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

        publishCommands()

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
}
