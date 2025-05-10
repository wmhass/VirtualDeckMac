//
//  InitialViewVision.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI

struct InitialViewVision: View {
    @EnvironmentObject var browserManager: MPCBrowserManager

    var body: some View {
        VStack {
            switch browserManager.browserState {
                case .didntSetup:
                    SetupView()
                case .didSetupButPeerIsNotAvailable:
                    DidSetupButPeerNotAvailable()
                case .didSetupAndPeerIsConnected:
                    PeerConnectedView()
            }
        }
        .padding()
    }

    struct DidSetupButPeerNotAvailable: View {

        @EnvironmentObject var browserManager: MPCBrowserManager

        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                Text("Waiting for Mac App...")
                    .font(.title)
                Text("Make sure the Mac App is running on \(browserManager.savedPeerInfo?.readableName ?? "-"). If you don't have the Mac App yet, download it at https://lilohass.com/actiondeck")
                    .font(.body)
                    .multilineTextAlignment(.center)
                Button("Pair again") {
                    browserManager.repair()
                }
            }
        }
    }

    struct SetupView: View {
        @State var pairCodeText: String = ""
        @State var selectedPeer: PeerInfo?
        @State var validationError: String?
        @EnvironmentObject var browserManager: MPCBrowserManager

        var body: some View {
            VStack(spacing: 20) {
                Spacer()
                if browserManager.availablePeers.isEmpty {
                    Text("No Macs Found")
                        .font(.title)
                    Text("Make sure the Mac App is running. If you don't have the Mac App yet, download it at https://lilohass.com/actiondeck")
                        .font(.body)
                } else {
                    Text("Enter Pair Code")
                        .font(.title)
                    TextField("1234", text: $pairCodeText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                        .padding(.horizontal)

                    Picker("Available peers", selection: $selectedPeer) {
                        ForEach(browserManager.availablePeers, id: \.self) { peer in
                            Text(peer.readableName).tag(peer as PeerInfo?)
                                .labelStyle(.titleOnly)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.caption2)
                    .task {
                        if selectedPeer == nil, let first = browserManager.availablePeers.first {
                            Task { @MainActor in
                                withAnimation {
                                    selectedPeer = first
                                }
                            }
                        }
                    }
                    .onChange(of: browserManager.availablePeers) {
                        Task { @MainActor in
                            withAnimation {
                                selectedPeer = browserManager.availablePeers.first
                            }
                        }
                    }
                    if let errorPairing = browserManager.errorPairing {
                        Text("\(errorPairing)").font(.caption)
                    }
                    if let validationError {
                        Text("\(validationError)").font(.caption)
                    }
                    Button(action: {
                        validationError = nil
                        guard let selectedPeer else {
                            validationError = "No peer selected"
                            return
                        }
                        guard pairCodeText.isEmpty == false else {
                            validationError = "Pair code can not be empty"
                            return
                        }
                        browserManager.pair(pairingCode: pairCodeText, peerId: selectedPeer.peerId)
                    }) {
                        Text(browserManager.connectionState == .connecting ? "Pairing..." : "Pair")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .disabled(browserManager.connectionState == .connecting)
                    }
                    .frame(width: 200)
                }
                Spacer()
            }

        }
    }

    struct PeerConnectedView: View {
        @EnvironmentObject var browserManager: MPCBrowserManager
        @State private var showUnpairConfirmation = false

        var body: some View {
            VStack(spacing: 4) {
                FixedGridView(commands: browserManager.commands, buttonClicked: { item in
                    sendCommand(item)
                })
                HStack {
                    Text("Connected to: \(browserManager.connectedPeer?.readableName ?? "-")")
                        .font(.caption)
                    Button("Unpair") {
                        showUnpairConfirmation = true
                    }
                    .font(.caption2)
                    .alert("Are you sure you want to unpair?", isPresented: $showUnpairConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Unpair", role: .destructive) {
                            browserManager.repair()
                        }
                    }
                }
            }
        }

        func sendCommand(_ command: IdentifiableCommand) {
            do {
                try browserManager.sendCrossDeviceMessage(CrossDeviceMessage(
                    messageType: .command(command: command)
                ))
            } catch {
                print("Error sending command: \(error)")
            }
        }
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
