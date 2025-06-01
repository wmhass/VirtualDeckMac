//
//  CrossDeviceMessage.swift
//  VirtualDeckMac
//
//  Created by William Hass on 2025-04-14.
//

import Foundation

struct CrossDeviceMessage: Codable {
    enum MessageType: Codable {
        case command(command: IdentifiableCommand)
        case commandsUpdate(commands: [IdentifiableCommand])
        case textMessage(text: String)
    }
    let messageType: MessageType
}

struct ConnectedPeer: Codable, Hashable {
    let readableName: String
    let peerId: String
}

struct IdentifiableCommand: Identifiable, Codable {
    let id: String
    let imageName: String
    let command: Command
}


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
