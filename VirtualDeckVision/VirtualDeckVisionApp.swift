//
//  VirtualDeckVisionApp.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-13.
//

import SwiftUI

@main
struct VirtualDeckVisionApp: App {
    let browserManager = MPCBrowserManager(
        browser: MPCBrowser(),
        storage: VisionProStorage()
    )

    var body: some Scene {
        WindowGroup {
            InitialViewVision(sendCommand: { command in
                do {
                    try browserManager.sendCrossDeviceMessage(CrossDeviceMessage(
                        messageType: .command(command: command)
                    ))
                } catch {
                    print("Error sending command: \(error)")
                }
            }).environmentObject(browserManager)
        }
        .defaultSize(width: 410, height: 360)
    }
}
