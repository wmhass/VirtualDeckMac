//
//  ContentView.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI

struct ContentView: View {
    @State private var messageToSend = ""
    @EnvironmentObject var browserDelegate: MPCBrowserDelegate
    let sendCommand: (IdentifiableCommand) -> Void

    var body: some View {
        VStack {
            Text("Connected Peers:")
                .font(.headline)
            ForEach(browserDelegate.connectedPeers, id: \.self) { p in
                Text(p)
                    .font(.subheadline)
            }

            FixedGridView(commands: browserDelegate.commands, buttonClicked: { item in
                sendCommand(item)
            })
        }
        .padding()
    }
}
#Preview(windowStyle: .automatic) {
    ContentView { _ in

    }
}

struct FixedGridView: View {
    let commands: [IdentifiableCommand]
    let buttonClicked: (IdentifiableCommand) -> Void

    let columns = [
        GridItem(.adaptive(minimum: 64, maximum: 64), spacing: 16)
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
                        .frame(width: 64, height: 64)
                    })
                    .cornerRadius(0.2)
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            .padding()
        }
    }
}
