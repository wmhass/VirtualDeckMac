//
//  CommandHandler.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-11.
//
import Foundation
import AppKit

class CommandHandler {
    func handleCommand(command: Command) {
        DispatchQueue.main.async {
            switch command.commandType {
            case .screenResize(let resizeType, let position):
                resizeFrontmostWindow(to: calculateFrame(resizeType: resizeType, positionType: position))
            }
        }
    }
}

func calculateFrame(resizeType: Command.ResizeType, positionType: Command.PositionType) -> CGRect {
    guard let screen = NSScreen.main else {
        return .zero
    }
    let screenFrame = screen.visibleFrame

    let size: CGSize = {
        switch resizeType {
            case .toFraction(width: let width, height: let height):
                return CGSize(width: screenFrame.width/width, height: screenFrame.height/height)
        }
    }()
    let position: CGPoint = {
        switch positionType {
            case .topLeft:
                return CGPoint(x: screenFrame.minX, y: screenFrame.minY)
            case .topRight:
                return CGPoint(x: screenFrame.maxX - size.width, y: screenFrame.minY)
            case .rightEdgeCenterOfScreen:
                return CGPoint(x: (screenFrame.width / 2) - size.width, y: screenFrame.minY)
            case .leftEdgeCenterOfScreen:
                return CGPoint(x: screenFrame.minX + (screenFrame.width / 2), y: screenFrame.minY)
            case .centered:
                return CGPoint(x: screenFrame.minX + (screenFrame.width - size.width) / 2, y: screenFrame.minY)
        }
    }()
    let frame = CGRect(origin: position, size: size)
    print("Screen frame: \(screenFrame) // Calculated frame: \(frame)")
    return frame
}

func resizeFrontmostWindow(to frame: CGRect) {
    print("Is trusted: \(AXIsProcessTrusted())")

    guard let frontApp = NSWorkspace.shared.menuBarOwningApplication else {
        print("App not found")
        return
    }
    print("Frontmost app: \(frontApp.localizedName ?? "Unknown")")
    print("PID: \(frontApp.processIdentifier)")

    let appRef = AXUIElementCreateApplication(frontApp.processIdentifier)
    print("Appref: \(appRef)")

    // Just print attributes for debug
    var attributeNames: CFArray?
    AXUIElementCopyAttributeNames(appRef, &attributeNames)
    if let attributes = attributeNames as? [String] {
        print("AX Attributes for frontmost app:")
        attributes.forEach { print("- \($0)") }
    }

    var windowRef: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(appRef, kAXFocusedWindowAttribute as CFString, &windowRef)
    print("AXUIElementCopyAttributeValue result: \(result.rawValue)") // 0 = success, -25205 = cannotComplete

    guard result == .success,
          let window = windowRef.map({ $0 as! AXUIElement }) else {
        print("Could not get focused window.")
        return
    }

    var position = frame.origin
    if let axPosition = AXValueCreate(.cgPoint, &position) {
        let positionResult = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, axPosition)
        print("Set position result: \(positionResult.rawValue)")
    }

    var size = frame.size
    if let axSize = AXValueCreate(.cgSize, &size) {
        let sizeResult = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, axSize)
        print("Set size result: \(sizeResult.rawValue)")
    }
}
