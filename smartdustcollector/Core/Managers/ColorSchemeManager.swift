//
//  ColorSchemeManager.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 25.01.2026.
//

import Cocoa

enum ColorScheme: String, CaseIterable {
    case grey = "Grey"
    case blue = "Blue"
    case green = "Green"
    case purple = "Purple"
    case orange = "Orange"
    case pink = "Pink"
    
    var displayName: String {
        rawValue
    }
    
    // Background color for app window
    var backgroundColor: NSColor {
        switch self {
        case .grey:
            return NSColor(red: 0.88, green: 0.88, blue: 0.90, alpha: 1.0)
        case .blue:
            return NSColor(red: 0.85, green: 0.90, blue: 0.95, alpha: 1.0)
        case .green:
            return NSColor(red: 0.88, green: 0.95, blue: 0.88, alpha: 1.0)
        case .purple:
            return NSColor(red: 0.92, green: 0.88, blue: 0.95, alpha: 1.0)
        case .orange:
            return NSColor(red: 0.98, green: 0.92, blue: 0.85, alpha: 1.0)
        case .pink:
            return NSColor(red: 0.98, green: 0.90, blue: 0.93, alpha: 1.0)
        }
    }
    
    // Cell fill color (gamefield cells)
    var cellFillColor: NSColor {
        switch self {
        case .grey:
            return NSColor(white: 0.75, alpha: 0.9)
        case .blue:
            return NSColor(red: 0.70, green: 0.80, blue: 0.90, alpha: 0.9)
        case .green:
            return NSColor(red: 0.70, green: 0.85, blue: 0.70, alpha: 0.9)
        case .purple:
            return NSColor(red: 0.80, green: 0.75, blue: 0.85, alpha: 0.9)
        case .orange:
            return NSColor(red: 0.95, green: 0.80, blue: 0.65, alpha: 0.9)
        case .pink:
            return NSColor(red: 0.95, green: 0.75, blue: 0.80, alpha: 0.9)
        }
    }
    
    // Cell stroke color
    var cellStrokeColor: NSColor {
        switch self {
        case .grey:
            return NSColor(white: 0.5, alpha: 0.6)
        case .blue:
            return NSColor(red: 0.50, green: 0.65, blue: 0.75, alpha: 0.6)
        case .green:
            return NSColor(red: 0.50, green: 0.70, blue: 0.50, alpha: 0.6)
        case .purple:
            return NSColor(red: 0.65, green: 0.60, blue: 0.70, alpha: 0.6)
        case .orange:
            return NSColor(red: 0.80, green: 0.65, blue: 0.50, alpha: 0.6)
        case .pink:
            return NSColor(red: 0.80, green: 0.60, blue: 0.65, alpha: 0.6)
        }
    }
    
    // Destroyed cell fill color
    var destroyedCellFillColor: NSColor {
        switch self {
        case .grey:
            return NSColor(white: 0.25, alpha: 0.8)
        case .blue:
            return NSColor(red: 0.30, green: 0.40, blue: 0.50, alpha: 0.8)
        case .green:
            return NSColor(red: 0.30, green: 0.50, blue: 0.30, alpha: 0.8)
        case .purple:
            return NSColor(red: 0.45, green: 0.40, blue: 0.50, alpha: 0.8)
        case .orange:
            return NSColor(red: 0.60, green: 0.50, blue: 0.35, alpha: 0.8)
        case .pink:
            return NSColor(red: 0.60, green: 0.45, blue: 0.50, alpha: 0.8)
        }
    }
    
    // Destroyed cell stroke color
    var destroyedCellStrokeColor: NSColor {
        switch self {
        case .grey:
            return NSColor(white: 0.15, alpha: 0.6)
        case .blue:
            return NSColor(red: 0.20, green: 0.30, blue: 0.40, alpha: 0.6)
        case .green:
            return NSColor(red: 0.20, green: 0.40, blue: 0.20, alpha: 0.6)
        case .purple:
            return NSColor(red: 0.35, green: 0.30, blue: 0.40, alpha: 0.6)
        case .orange:
            return NSColor(red: 0.50, green: 0.40, blue: 0.25, alpha: 0.6)
        case .pink:
            return NSColor(red: 0.50, green: 0.35, blue: 0.40, alpha: 0.6)
        }
    }
    
    // Button text color
    var buttonTextColor: NSColor {
        switch self {
        case .grey:
            return NSColor.gray
        case .blue:
            return NSColor(red: 0.20, green: 0.40, blue: 0.60, alpha: 1.0)
        case .green:
            return NSColor(red: 0.20, green: 0.50, blue: 0.20, alpha: 1.0)
        case .purple:
            return NSColor(red: 0.50, green: 0.30, blue: 0.60, alpha: 1.0)
        case .orange:
            return NSColor(red: 0.80, green: 0.50, blue: 0.20, alpha: 1.0)
        case .pink:
            return NSColor(red: 0.80, green: 0.30, blue: 0.50, alpha: 1.0)
        }
    }
    
    // Button hover color (lighter version)
    var buttonHoverColor: NSColor {
        switch self {
        case .grey:
            return NSColor.gray.withAlphaComponent(0.8)
        case .blue:
            return NSColor(red: 0.20, green: 0.40, blue: 0.60, alpha: 0.8)
        case .green:
            return NSColor(red: 0.20, green: 0.50, blue: 0.20, alpha: 0.8)
        case .purple:
            return NSColor(red: 0.50, green: 0.30, blue: 0.60, alpha: 0.8)
        case .orange:
            return NSColor(red: 0.80, green: 0.50, blue: 0.20, alpha: 0.8)
        case .pink:
            return NSColor(red: 0.80, green: 0.30, blue: 0.50, alpha: 0.8)
        }
    }
    
    // Active button background color (for settings buttons)
    var activeButtonBackgroundColor: NSColor {
        switch self {
        case .grey:
            return NSColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0)
        case .blue:
            return NSColor(red: 0.30, green: 0.50, blue: 0.70, alpha: 1.0)
        case .green:
            return NSColor(red: 0.30, green: 0.60, blue: 0.30, alpha: 1.0)
        case .purple:
            return NSColor(red: 0.60, green: 0.40, blue: 0.70, alpha: 1.0)
        case .orange:
            return NSColor(red: 0.90, green: 0.60, blue: 0.30, alpha: 1.0)
        case .pink:
            return NSColor(red: 0.90, green: 0.40, blue: 0.60, alpha: 1.0)
        }
    }
}

class ColorSchemeManager {
    static let shared = ColorSchemeManager()
    
    private let colorSchemeKey = "SelectedColorScheme"
    private let userDefaults = UserDefaults.standard
    
    var currentScheme: ColorScheme {
        get {
            guard let rawValue = userDefaults.string(forKey: colorSchemeKey),
                  let scheme = ColorScheme(rawValue: rawValue) else {
                return .grey // Default
            }
            return scheme
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: colorSchemeKey)
            NotificationCenter.default.post(name: .colorSchemeDidChange, object: nil)
        }
    }
    
    private init() {}
}

extension Notification.Name {
    static let colorSchemeDidChange = Notification.Name("colorSchemeDidChange")
}
