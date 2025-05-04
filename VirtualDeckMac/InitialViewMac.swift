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
    @State private var showPairCodeInputText: Bool = false
    @EnvironmentObject private var appDelegate: AppDelegate
    @State private var hasAccessibilityEnabled: Bool = true

    var body: some View {
        VStack(spacing: 24) {
            if !hasAccessibilityEnabled {
                Text("Accessibility Permission Required")
                    .font(.title)
                Text("Open System Settings > Privacy & Security > Accessibility and give ActionDeck accessibility permission to be able to resize windows and trigger shortcuts.")
            }
            VStack(spacing: 8) {
                Text("Connected devices")
                    .font(.title)
                if appDelegate.connectedClients.isEmpty {
                    Text("No devices connected.")
                        .font(.caption)
                } else {
                    VStack {
                        ForEach(appDelegate.connectedClients, id: \.self) { clientName in
                            Text(clientName).font(.subheadline)
                        }
                    }
                }
            }
            if !showPairCodeInputText {
                Button("Pair a new device") {
                    let code = Int.random(in: 1000...9999)
                    appDelegate.storage.store(pairingCode: String(code))
                    showPairCodeInputText = true
                }
            } else {
                VStack(spacing: 8) {
                    Text("Your pairing code")
                        .font(.title3)
                    Text(appDelegate.storage.pairingCode ?? "-")
                        .font(.largeTitle)
                    Text("Type this in your Vision Pro")
                        .font(.caption)
                    HStack {
                        Button("Cancel") {
                            showPairCodeInputText = false
                        }
                    }

                }
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
