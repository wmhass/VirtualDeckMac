//
//  Commands.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-14.
//


struct Command: Codable {

    enum ResizeType: Codable {
        case toFraction(width: Double, height: Double)
    }
    enum PositionType: Codable {
        case topLeft
        case topRight
        case rightEdgeCenterOfScreen
        case leftEdgeCenterOfScreen
        case centered
    }

    enum CommandType: Codable {
        case screenResize(resizeType: ResizeType, position: PositionType)
    }

    let commandType: CommandType

}
