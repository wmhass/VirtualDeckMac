//
//  main.swift
//  VirtualDeckMacXPC
//
//  Created by William Hass on 2025-04-15.
//

import Foundation


let server = XPCServer()
let listener = NSXPCListener.service()
listener.delegate = server
listener.resume()
