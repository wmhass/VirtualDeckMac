//
//  VirtualDeckVisionApp.swift
//  VirtualDeckVision
//
//  Created by William Hass on 2025-04-13.
//

import SwiftUI

@main
struct VirtualDeckVisionApp: App {
    var body: some Scene {
        WindowGroup {
//            GeometryReader { geometry in
//                let size = geometry.size
//                Color.clear
//                    .onChange(of: size) { newSize, oldSize in
//                        print("Window size changed to: \(newSize.width) x \(newSize.height)")
//                    }
//            }
            ContentView()
        }
        .defaultSize(width: 410, height: 360)
    }
}
