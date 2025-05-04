//
//  VirtualDeckVisionApp.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-13.
//

import SwiftUI

@main
struct VirtualDeckVisionApp: App {
    let browserDelegate = MPCBrowserDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView(sendCommand: { command in
                do {
                    try browserDelegate.browser.sendCrossDeviceMessage(CrossDeviceMessage(
                        messageType: .command(command: command)
                    ))
                } catch {
                    print("Error sending command: \(error)")
                }
            }).environmentObject(browserDelegate)
        }
        .defaultSize(width: 410, height: 360)
    }
}
