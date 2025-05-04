//
//  ContentView.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI
import Cocoa
import ApplicationServices

struct ContentView: View {
    @State private var messageToSend = ""
    @EnvironmentObject private var appDelegate: AppDelegate
    @State private var showPairCodeInputText: Bool = false

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
                    appDelegate.storage.store(authCode: String(code))
                    showPairCodeInputText = true
                }
            } else {
                VStack(spacing: 8) {
                    Text("Your pairing code")
                        .font(.title3)
                    Text(appDelegate.storage.authCode ?? "-")
                        .font(.largeTitle)
                    Text("Type this in your Vision Pro")
                        .font(.caption)
                    HStack {
                        Button("Cancel") {
                            showPairCodeInputText = false
                        }
                        Button("Pair") {
                            showPairCodeInputText = false
                        }
                    }

                }
            }
        }
        .frame(width: 300, height: 300)
        /*VStack {
         Text("Connected Peers:")
         .font(.headline)
         ForEach(appDelegate.connectedClients, id: \.self) { p in
         Text(p)
         .font(.subheadline)
         }

         Divider().padding()

         ScrollView {
         VStack(alignment: .leading) {
         ForEach(appDelegate.messages, id: \.self) { msg in
         Text(msg)
         .padding(4)
         .frame(maxWidth: .infinity, alignment: .leading)
         .background(Color.gray.opacity(0.1))
         .cornerRadius(5)
         }
         }
         }
         .frame(maxHeight: 300)

         HStack {
         TextField("Type a message", text: $messageToSend)
         .textFieldStyle(RoundedBorderTextFieldStyle())
         Button("Send") {
         try? appDelegate.xpcServer?.handleMessageFromClient(
         xpcMessage: XPCMessage(
         messageType: .crossDeviceMessage(
         message: CrossDeviceMessage(
         messageType: .textMessage(text: messageToSend)
         )
         )
         )
         )
         print("XPC Server: \(String(describing: appDelegate.xpcServer))")
         messageToSend = ""
         }
         }
         .padding()
         }
         .padding()*/
    }
}
