//
//  HelperAppLauncher.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-13.
//

import AppKit

class HelperAppLauncher {
    func launchIfNeeded() {
        let helperBundleID = "com.williamhass.VirtualDeckMacHelperApp"
        var isHelperRunning = NSRunningApplication.runningApplications(withBundleIdentifier: helperBundleID).isEmpty == false
        if !isHelperRunning {
            let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/VirtualDeckMacHelperApp.app")
            NSWorkspace.shared.openApplication(at: helperURL, configuration: .init())
        } else {
            print("✅ Helper is already running.")
        }
        while !isHelperRunning {
            print("Waiting for app to start...")
            isHelperRunning = NSRunningApplication.runningApplications(withBundleIdentifier: helperBundleID).isEmpty == false
        }
        print("App started!")
    }
}
