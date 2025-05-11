//
//  InitialViewMac.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI
import Cocoa
import ApplicationServices

struct InitialViewMac: View {
    @State private var messageToSend = ""
    @EnvironmentObject private var appDelegate: AppDelegate
    @State private var hasAccessibilityEnabled: Bool = true

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Connected devices")
                    .font(.title)
                if appDelegate.connectedPeers.isEmpty {
                    Text("No devices connected.")
                        .font(.caption)
                } else {
                    VStack {
                        ForEach(appDelegate.connectedPeers, id: \.self) { connectedPeer in
                            HStack {
                                Text(connectedPeer.readableName).font(.subheadline)
                                Button("Remove") {
                                    appDelegate.removeConnectedPeer(connectedPeer)
                                }
                            }
                        }
                    }
                }
            }
            if appDelegate.isPairing {
                VStack(spacing: 8) {
                    Text("Your pairing code")
                        .font(.title3)
                    Text(appDelegate.storage.pairingCode ?? "-")
                        .font(.largeTitle)
                    Text("Type this in your Vision Pro")
                        .font(.caption)
                    HStack {
                        Button("Cancel") {
                            appDelegate.cancelPairing()
                        }
                    }
                }
            } else {
                Button("Pair a new device") {
                    appDelegate.prepareForPairing()
                }
            }
            if !hasAccessibilityEnabled {
                VStack(spacing: 8) {
                    Text("Accessibility Permission Required")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    Text("Open System Settings > Privacy & Security > Accessibility and give ActionDeck accessibility permission to be able to resize windows and trigger shortcuts.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
            HStack {
                Text("Need help? https://lilohass.com/contact or email wm.hass@gmail.com").font(.caption2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 300, height: 400)
        .onAppear {
            if !AXIsProcessTrusted() {
                let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
                let trusted = AXIsProcessTrustedWithOptions(options)
                hasAccessibilityEnabled = trusted
            }
        }
    }
}

#Preview {
    InitialViewMac()
        .environmentObject(AppDelegate())
}
