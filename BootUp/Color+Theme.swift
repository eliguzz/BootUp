//
//  Color+Theme.swift
//  BootUp
//
//  Created by Eli on 5/12/26.
//

import Foundation
import SwiftUI

extension Color {
    // Terminal/CRT green — the primary accent for everything readable
    static let terminal = Color(red: 0.18, green: 1.0, blue: 0.45)
    
    // Same hue, dimmed for secondary text
    static let terminalDim = Color(red: 0.18, green: 1.0, blue: 0.45).opacity(0.55)
    
    // Same hue, very faint for backgrounds and disabled state
    static let terminalFaint = Color(red: 0.18, green: 1.0, blue: 0.45).opacity(0.25)
    
    // Near-black background — softer than pure black on OLED
    static let appBackground = Color(red: 0.06, green: 0.06, blue: 0.06)
}
