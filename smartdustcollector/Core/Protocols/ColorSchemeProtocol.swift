//
//  ColorSchemeProtocol.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 31.01.2026.
//

import Cocoa

/// Protocol for view controllers that support color scheme changes
protocol ColorSchemeApplicable: AnyObject {
    func applyColorScheme()
}

extension ColorSchemeApplicable where Self: NSViewController {
    /// Default implementation for applying color scheme to view background
    func applyColorScheme() {
        let scheme = ColorSchemeManager.shared.currentScheme
        view.layer?.backgroundColor = scheme.backgroundColor.cgColor
    }
    
    /// Setup color scheme change observer using closure-based API (no @objc needed)
    func setupColorSchemeObserver() {
        NotificationCenter.default.addObserver(
            forName: .colorSchemeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyColorScheme()
        }
    }
    
    /// Remove color scheme change observer
    func removeColorSchemeObserver() {
        NotificationCenter.default.removeObserver(self, name: .colorSchemeDidChange, object: nil)
    }
}
