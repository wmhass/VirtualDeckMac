//
//  VirtualDeckVisionApp.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-13.
//

import SwiftUI

import MultipeerConnectivity
class PeerDelegate: MultipeerManagerDelegate, ObservableObject {
    @Published var commands: [IdentifiableCommand] = []
    func handleNewMessage(clientId: String, data: Data) {
        let crossDeviceMessage = try! JSONDecoder().decode(CrossDeviceMessage.self, from: data)
        switch crossDeviceMessage.messageType {
            case .command(command: let command):
                print("Apple vision pro received command")
            case .commandsUpdate(commands: let commands):
                DispatchQueue.main.async {
                    self.commands = commands
                }
            case .textMessage(text: let text):
                break;
        }
    }
    func clientsChanged(_ clients: [MCPeerID]) {
    }
}

@main
struct VirtualDeckVisionApp: App {
    let peer = MultipeerManager()
    let peerDelegate = PeerDelegate()

    init() {
        peer.delegate = peerDelegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(peer)
                .environmentObject(peerDelegate)
        }
        .defaultSize(width: 410, height: 360)
    }
}
