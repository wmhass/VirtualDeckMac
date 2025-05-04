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

    var body: some View {
        VStack(spacing: 24) {
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
        .frame(width: 300, height: 300)
    }
}

#Preview {
    InitialViewMac()
        .environmentObject(AppDelegate())
}
