//
//  VirtualDeckMacApp.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI
import SwiftData

// MARK: New
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var xpcServer: XPCServerProtocol?
    let helperAppLauncher = HelperAppLauncher()
    var connection: NSXPCConnection?
    let commandHandler = MultiPeerCommandHandler()

    @Published var messages: [String] = []
    @Published var connectedClients: [String] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ AppDelegate: did finish launching")
        // xpcListener.startListening()
        // helperAppLauncher.launchIfNeeded()

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

        let someData = String("").data(using: .utf8)
        xpcServer?.send(data: someData!)

        print("XPC Server: \(String(describing: xpcServer))")

        publishCommands()
    }
}

extension AppDelegate: XPCClientProtocol {
    func handleNewMessage(clientId: String, data: Data) {
        print("Hanlde new message")
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
        print("Clients updated")
        DispatchQueue.main.async {
             self.connectedClients = clients
        }
        publishCommands()
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
        let data = try! JSONEncoder().encode(crossDeviceMessage)
        xpcServer?.send(data: data)
    }
}

@main
struct VirtualDeckMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate)
        }
        .modelContainer(sharedModelContainer)
    }
}
