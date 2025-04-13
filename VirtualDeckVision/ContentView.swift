//
//  ContentView.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var peer = MultipeerManager()
    @State private var messageToSend = ""

    var body: some View {
        VStack {
            Text("Connected Peers:")
                .font(.headline)
            ForEach(peer.connectedPeers, id: \.self) { p in
                Text(p.displayName)
                    .font(.subheadline)
            }
//            Text("Messages:")
//                .font(.headline)
//            ForEach(peer.messages, id: \.self) { m in
//                Text(m)
//                    .font(.subheadline)
//            }

            FixedGridView(buttonClicked: { buttonIndex in
                peer.send("\(buttonIndex)")
            })
        }
        .padding()
    }
}
#Preview(windowStyle: .automatic) {
    ContentView()
}


struct FixedGridView: View {
    let items = Array(1...20)
    let buttonClicked: (Int) -> Void

    let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 60), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        buttonClicked(item)
                    }, label: {
                        VStack {
                            Image("command_\(item)")
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
