//
//  InitialViewVision.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI

struct InitialViewVision: View {
    @State private var messageToSend = ""
    @EnvironmentObject var browserManager: MPCBrowserManager
    let sendCommand: (IdentifiableCommand) -> Void
    let storage = VisionProStorage()

    @State var pairCodeText: String = ""

    var body: some View {
        VStack {
            if !browserManager.hasAdvertiserSetup {
                VStack(spacing: 20) {
                    Spacer()
                    Text("Enter Pair Code")
                        .font(.title)
                    TextField("1234", text: $pairCodeText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                        .padding(.horizontal)

                    Button(action: {
                        browserManager.pair(pairingCode: pairCodeText)
                    }) {
                        Text("Pair")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .frame(width: 200)
                    Spacer()
                }
            } else {
                VStack(spacing: 4) {
                    FixedGridView(commands: browserManager.commands, buttonClicked: { item in
                        sendCommand(item)
                    })
                    HStack {
                        Text("Connected to:")
                            .font(.caption)
                        ForEach(browserManager.connectedPeers, id: \.self) { p in
                            Text(p)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
#Preview(windowStyle: .automatic) {
    InitialViewVision { _ in

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
