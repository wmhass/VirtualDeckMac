//
//  VirtualDeckMacApp.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-10.
//

import SwiftUI
import SwiftData

// MARK: New
class AppDelegate: NSObject, NSApplicationDelegate {
    let xpcListener = XPCListener()
    let helperAppLauncher = HelperAppLauncher()

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ AppDelegate: did finish launching")
        xpcListener.startListening()
        helperAppLauncher.launchIfNeeded()
    }
}

@main
struct VirtualDeckMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.xpcListener)
        }
        .modelContainer(sharedModelContainer)
    }
}
