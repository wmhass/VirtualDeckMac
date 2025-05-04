//
//  VirtualDeckMacApp.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI

@main
struct VirtualDeckMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            InitialViewMac()
                .environmentObject(appDelegate)
        }
        .windowResizability(.contentSize)
    }
}
