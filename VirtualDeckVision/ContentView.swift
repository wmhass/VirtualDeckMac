//
//  ContentView.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI

struct ContentView: View {
    @State private var messageToSend = ""
    @EnvironmentObject var peer: MultipeerManager
    @EnvironmentObject var peerDelegate: PeerDelegate

    var body: some View {
        VStack {
            Text("Connected Peers:")
                .font(.headline)
            ForEach(peer.connectedPeers, id: \.self) { p in
                Text(p.displayName)
                    .font(.subheadline)
            }

            FixedGridView(commands: peerDelegate.commands, buttonClicked: { item in
                let crossDeviceMessage = CrossDeviceMessage(messageType: .command(command: item))
                let dataCommand = try! JSONEncoder().encode(crossDeviceMessage)
                peer.send(data: dataCommand)
            })
        }
        .padding()
    }
}
#Preview(windowStyle: .automatic) {
    ContentView()
}

struct FixedGridView: View {
    let commands: [IdentifiableCommand]
    let buttonClicked: (IdentifiableCommand) -> Void

    let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 60), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(commands) { item in
                    Button(action: {
                        buttonClicked(item)
                    }, label: {
                        VStack {
                            Image(item.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 36)
                        }
                        .frame(width: 60, height: 60)
                    })
                    .cornerRadius(1)
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            .padding()
        }
    }
}
