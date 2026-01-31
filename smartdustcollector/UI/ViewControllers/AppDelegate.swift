//
//  AppDelegate.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import Cocoa
import SpriteKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?
    var gameWindowController: NSWindowController?
    var statusBarMenu: NSMenu?
    
    // Expose popover for view controller access
    static var shared: AppDelegate {
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return delegate
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Show app in dock
        NSApp.setActivationPolicy(.regular)
        
        // Close any existing windows
        for window in NSApp.windows {
            window.close()
        }
        
        // Create status bar item
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem?.button {
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "gamecontroller.fill", accessibilityDescription: "Smart Relax")
            } else {
                // Fallback: create a simple icon
                let icon = NSImage(size: NSSize(width: 18, height: 18))
                icon.lockFocus()
                NSColor.systemBlue.setFill()
                NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 14, height: 14)).fill()
                icon.unlockFocus()
                button.image = icon
            }
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Create right-click menu
        setupStatusBarMenu()
        
        // Create popover
        popover = NSPopover()
        popover?.behavior = .transient
        popover?.contentViewController = createGameViewController()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show popover when clicking dock icon (same as menu bar icon)
        togglePopover()
        return true
    }
    
    func showMainWindow() {
        // If window already exists and is visible, just bring it to front
        if let windowController = gameWindowController, let window = windowController.window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // Create window controller if it doesn't exist
        if gameWindowController == nil {
            // Create game view controller
            let gameViewController = createGameViewController()
            
            // Calculate optimal window size (same as popover)
            let windowSize = gameViewController.view.frame.size
            
            // Create window
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "StarDust Collector"
            window.contentViewController = gameViewController
            window.center()
            window.setFrameAutosaveName("MainWindow")
            
            // Create window controller
            gameWindowController = NSWindowController(window: window)
        }
        
        // Show window
        gameWindowController?.showWindow(nil)
        gameWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc
    func togglePopover() {
        guard let button = statusBarItem?.button,
              let popover = popover else { return }
        
        // Check if right mouse button was clicked
        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            // Show menu instead of popover
            statusBarMenu?.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
            return
        }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            // Ensure popover size matches view controller size
            if let viewController = popover.contentViewController {
                popover.contentSize = viewController.view.frame.size
            }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func setupStatusBarMenu() {
        let menu = NSMenu()
        
        // Settings menu item with icon
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: "")
        settingsItem.target = self
        if #available(macOS 11.0, *) {
            settingsItem.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "Settings")
        }
        menu.addItem(settingsItem)
        
        // Separator
        menu.addItem(NSMenuItem.separator())
        
        // About menu item with icon
        let aboutItem = NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        if #available(macOS 11.0, *) {
            aboutItem.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "About")
        }
        menu.addItem(aboutItem)
        
        // Separator
        menu.addItem(NSMenuItem.separator())
        
        // Quit Game menu item with icon
        let quitItem = NSMenuItem(title: "Quit Game", action: #selector(closeGame), keyEquivalent: "")
        quitItem.target = self
        if #available(macOS 11.0, *) {
            quitItem.image = NSImage(systemSymbolName: "power", accessibilityDescription: "Quit Game")
        }
        menu.addItem(quitItem)
        
        // Store menu but don't assign it to statusBarItem (which would make it show on left-click)
        statusBarMenu = menu
    }
    
    @objc
    func showSettings() {
        guard let popover = popover,
              let gameContainerVC = popover.contentViewController as? GameContainerViewController,
              let button = statusBarItem?.button else { return }
        
        // Show popover if not already shown
        if !popover.isShown {
            if let viewController = popover.contentViewController {
                popover.contentSize = viewController.view.frame.size
            }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
        
        // Switch to settings view
        gameContainerVC.showSettingsView()
    }
    
    @objc
    func showAbout() {
        guard let popover = popover,
              let gameContainerVC = popover.contentViewController as? GameContainerViewController,
              let button = statusBarItem?.button else { return }
        
        // Show popover if not already shown
        if !popover.isShown {
            if let viewController = popover.contentViewController {
                popover.contentSize = viewController.view.frame.size
            }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
        
        // Switch to about view
        gameContainerVC.showAboutView()
    }
    
    @objc
    func closeGame() {
        NSApplication.shared.terminate(nil)
    }
    
    func createGameViewController() -> NSViewController {
        let viewController = GameContainerViewController()
        // Size is set in loadView() - update popover to match
        if let popover = popover {
            popover.contentSize = viewController.view.frame.size
        }
        return viewController
    }
}
