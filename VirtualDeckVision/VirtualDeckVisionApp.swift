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
            InitialViewVision()
                .environmentObject(browserManager)
        }
        .defaultSize(width: 410, height: 360)
    }
}
