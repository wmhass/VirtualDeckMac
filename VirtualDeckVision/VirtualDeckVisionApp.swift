//
//  VirtualDeckVisionApp.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-13.
//

import SwiftUI

import MultipeerConnectivity
class MPCBrowserDelegate: NSObject, MCSessionDelegate, ObservableObject {

    let browser = MPCBrowser()
    @Published var commands: [IdentifiableCommand] = []
    @Published var connectedPeers: [String] = []

    override init() {
        super.init()
        browser.sessionDelegateBridge = self
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers.compactMap { peerId in
                self.browser.peerIdDiscoveryInfo[peerId]?["readableName"]
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let crossDeviceMessage = try! JSONDecoder().decode(CrossDeviceMessage.self, from: data)
        switch crossDeviceMessage.messageType {
            case .commandsUpdate(commands: let commands):
                DispatchQueue.main.async {
                    self.commands = commands
                }
            case .command, .textMessage:
                print("Browser does not support those commands")
                break;
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
    }


}

@main
struct VirtualDeckVisionApp: App {
    let browserDelegate = MPCBrowserDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView(sendCommand: { command in
                do {
                    try browserDelegate.browser.sendCrossDeviceMessage(CrossDeviceMessage(
                        messageType: .command(command: command)
                    ))
                } catch {
                    print("Error sending command: \(error)")
                }
            }).environmentObject(browserDelegate)
        }
        .defaultSize(width: 410, height: 360)
    }
}
