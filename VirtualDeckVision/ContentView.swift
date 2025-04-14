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

    let commands: [IdentifiableCommand] = [
        IdentifiableCommand(
            id: "1",
            imageName: "command_1",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 6, height: 1),
                position: .topLeft
            ))),
        IdentifiableCommand(
            id: "2",
            imageName: "command_2",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 3, height: 1),
                position: .topLeft
            ))),
        IdentifiableCommand(
            id: "3",
            imageName: "command_3",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 3, height: 1),
                position: .rightEdgeCenterOfScreen
            ))),
        IdentifiableCommand(
            id: "4",
            imageName: "command_4",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 2, height: 1),
                position: .rightEdgeCenterOfScreen
            ))),
        IdentifiableCommand(
            id: "5",
            imageName: "command_5",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 2, height: 1),
                position: .leftEdgeCenterOfScreen
            ))),
        IdentifiableCommand(
            id: "6",
            imageName: "command_6",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 3, height: 1),
                position: .leftEdgeCenterOfScreen
            ))),
        IdentifiableCommand(
            id: "7",
            imageName: "command_7",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 3, height: 1),
                position: .topRight
            ))),
        IdentifiableCommand(
            id: "8",
            imageName: "command_8",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 6, height: 1),
                position: .topRight
            ))),
        IdentifiableCommand(
            id: "9",
            imageName: "command_9",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 3, height: 1),
                position: .centered
            ))),
        IdentifiableCommand(
            id: "10",
            imageName: "command_10",
            command: Command(commandType: .screenResize(
                resizeType: .toFraction(width: 2, height: 1),
                position: .centered
            )))
    ]

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

            FixedGridView(commands: commands, buttonClicked: { item in
                // peer.send("\(buttonIndex)")
                peer.send(command: item.command)
            })
        }
        .padding()
    }
}
#Preview(windowStyle: .automatic) {
    ContentView()
}

struct IdentifiableCommand: Identifiable {
    let id: String
    let imageName: String
    let command: Command
}


struct FixedGridView: View {
    let items = Array(1...20)
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
