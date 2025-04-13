//
//  VirtualDeckMacHelperAppApp.swift
//  VirtualDeckMacHelperApp
//
//  Created by William Hass on 2025-04-12.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let bridge = XPCBridge()

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ AppDelegate: did finish launching")
        NSApplication.shared.setActivationPolicy(.prohibited)
    }
}

@main
struct VirtualDeckMacHelperAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
