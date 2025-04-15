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

    var body: some View {
        VStack {
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
                    let dataToSend = try! JSONEncoder().encode(CrossDeviceMessage(messageType: .textMessage(text: messageToSend)))
                    appDelegate.xpcServer?.send(data: dataToSend)
                    print("XPC Server: \(String(describing: appDelegate.xpcServer))")
                    messageToSend = ""
                }
            }
            .padding()
        }
        .padding()
    }
}
