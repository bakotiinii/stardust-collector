//
//  GameContainerViewController.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import Cocoa
import SpriteKit

enum ViewMode {
    case game
    case settings
    case statistics
    case about
}

class GameContainerViewController: NSViewController,
                                    GameSceneDelegate,
                                    SettingsViewControllerDelegate,
                                    StatisticsViewControllerDelegate,
                                    AboutViewControllerDelegate {
    var skView: SKView!
    var currentMode: ViewMode = .game
    var gameViewController: NSViewController?
    var settingsViewController: SettingsViewController?
    var statisticsViewController: StatisticsViewController?
    var aboutViewController: AboutViewController?
    var currentDifficulty: Difficulty = .easy
    
    func gameSceneDidChangeDifficulty(_ scene: GameScene, optimalSize: CGSize) {
        // Resize window and update scene
        resizeWindowToSize(optimalSize)
        
        // Update scene size and restart game
        if let gameScene = skView.scene as? GameScene {
            gameScene.size = optimalSize
            // Restart game with new difficulty (this will create new grid)
            gameScene.restartGameAfterResize()
        }
    }
    
    func settingsViewControllerDidSelectDifficulty(_ controller: SettingsViewController, difficulty: Difficulty) {
        currentDifficulty = difficulty
        // Update difficulty in game scene (but stay on settings page)
        if let gameScene = skView.scene as? GameScene {
            gameScene.difficulty = difficulty
            // Immediately resize window to optimal size for new difficulty to prevent fat borders
            let optimalSize = gameScene.calculateOptimalSize()
            resizeWindowToSize(optimalSize)
        }
    }
    
    func repositionWindowUnderGamepadIcon() {
        guard let popover = findPopover(),
              popover.isShown,
              let window = view.window,
              let button = AppDelegate.shared.statusBarItem?.button,
              let buttonWindow = button.window else { return }
        
        // Get current window size (use popover contentSize for accuracy)
        let currentSize = popover.contentSize
        
        // Get button frame in screen coordinates
        let buttonFrame = button.convert(button.bounds, to: nil)
        let buttonScreenRect = buttonWindow.convertToScreen(buttonFrame)
        
        // Calculate button center X and bottom Y in screen coordinates
        let buttonCenterX = buttonScreenRect.midX
        let buttonBottomY = buttonScreenRect.minY  // Bottom edge of button
        
        // Position window so its top edge is at the button's bottom edge
        // macOS uses bottom-left origin for screen coordinates
        let windowY = buttonBottomY - currentSize.height
        
        // Center window horizontally on button
        let windowX = buttonCenterX - currentSize.width / 2
        
        let targetFrame = NSRect(
            x: windowX,
            y: windowY,
            width: currentSize.width,
            height: currentSize.height
        )
        
        // Reposition window to keep it centered directly under the button
        window.setFrame(targetFrame, display: true, animate: false)
        
        // Force layout update to ensure everything is properly rendered
        view.needsLayout = true
        view.layout()
    }
    
    func resizeWindowToSize(_ newSize: CGSize) {
        guard let popover = findPopover(),
              let button = AppDelegate.shared.statusBarItem?.button else { return }
        
        let oldSize = popover.contentSize
        
        // Only resize if size actually changed
        guard oldSize != newSize else { return }
        
        // Update view frame
        view.frame = NSRect(origin: .zero, size: newSize)
        
        // Update skView frame to exactly match view bounds
        skView.frame = view.bounds
        
        // Update game scene size if in game mode
        if currentMode == .game, let gameScene = skView.scene as? GameScene {
            gameScene.size = view.bounds.size
        }
        
        // Update settings view frame if it's currently visible
        if currentMode == .settings, let settingsVC = settingsViewController {
            settingsVC.view.frame = view.bounds
        }
        
        // Update statistics view frame if it's currently visible
        if currentMode == .statistics, let statsVC = statisticsViewController {
            statsVC.view.frame = view.bounds
        }
        
        // Update about view frame if it's currently visible
        if currentMode == .about, let aboutVC = aboutViewController {
            aboutVC.view.frame = view.bounds
        }
        
        // Reposition popover window to keep it centered directly under the button
        // Calculate position BEFORE setting contentSize to avoid timing issues
        var targetFrame: NSRect?
        if popover.isShown, let window = view.window, let buttonWindow = button.window {
            // Get button frame in screen coordinates
            let buttonFrame = button.convert(button.bounds, to: nil)
            let buttonScreenRect = buttonWindow.convertToScreen(buttonFrame)
            
            // Calculate button center X and bottom Y in screen coordinates
            let buttonCenterX = buttonScreenRect.midX
            let buttonBottomY = buttonScreenRect.minY  // Bottom edge of button
            
            // Position window so its top edge is at the button's bottom edge
            // macOS uses bottom-left origin for screen coordinates
            let windowY = buttonBottomY - newSize.height
            
            // Center window horizontally on button
            let windowX = buttonCenterX - newSize.width / 2
            
            targetFrame = NSRect(
                x: windowX,
                y: windowY,
                width: newSize.width,
                height: newSize.height
            )
        }
        
        // Set new content size for popover (this resizes the window instantly)
        popover.contentSize = newSize
        
        // Immediately reposition window to keep it anchored to the button
        if let frame = targetFrame, let window = view.window {
            window.setFrame(frame, display: true, animate: false)
        }
        
        // Also reposition after a brief delay to ensure it stays correct
        // This handles cases where macOS might adjust the position after contentSize change
        if popover.isShown {
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let popover = self.findPopover(),
                      popover.isShown,
                      let window = self.view.window,
                      let button = AppDelegate.shared.statusBarItem?.button,
                      let buttonWindow = button.window else { return }
                
                // Recalculate button position
                let buttonFrame = button.convert(button.bounds, to: nil)
                let buttonScreenRect = buttonWindow.convertToScreen(buttonFrame)
                
                let buttonCenterX = buttonScreenRect.midX
                let buttonBottomY = buttonScreenRect.minY
                
                let windowY = buttonBottomY - newSize.height
                let windowX = buttonCenterX - newSize.width / 2
                
                let correctFrame = NSRect(
                    x: windowX,
                    y: windowY,
                    width: newSize.width,
                    height: newSize.height
                )
                
                // Only reposition if current position is different (avoid unnecessary updates)
                if abs(window.frame.origin.x - correctFrame.origin.x) > 1 ||
                   abs(window.frame.origin.y - correctFrame.origin.y) > 1 {
                    window.setFrame(correctFrame, display: true, animate: false)
                }
            }
        }
        
        // Force layout update to ensure everything is properly sized
        view.needsLayout = true
        view.layout()
    }
    
    func settingsViewControllerDidRequestBack(_ controller: SettingsViewController) {
        // Update difficulty in game scene first (window should already be resized from settingsViewControllerDidSelectDifficulty)
        if let gameScene = skView.scene as? GameScene {
            gameScene.difficulty = currentDifficulty
        }
        // Switch back to game view - window should already be correct size
        showGameView()
        // Ensure game is restarted with new difficulty
        if let gameScene = skView.scene as? GameScene {
            gameScene.restartGameAfterResize()
        }
    }
    
    func statisticsViewControllerDidRequestBack(_ controller: StatisticsViewController) {
        showGameView()
    }
    
    func aboutViewControllerDidRequestBack(_ controller: AboutViewController) {
        showGameView()
    }
    
    func findPopover() -> NSPopover? {
        // Access popover through AppDelegate
        AppDelegate.shared.popover
    }
    
    override func loadView() {
        // Calculate optimal size for easy mode (default)
        // Easy mode: 9x9 grid, min cell size 25
        let gridSize: Int = 9
        let minCellSize: CGFloat = 25
        let gridSpacing: CGFloat = 2
        let sidePadding: CGFloat = 20
        let topPadding: CGFloat = 80
        let bottomPadding: CGFloat = 70
        
        let gridWidth = CGFloat(gridSize) * minCellSize + CGFloat(gridSize - 1) * gridSpacing
        let gridHeight = CGFloat(gridSize) * minCellSize + CGFloat(gridSize - 1) * gridSpacing
        let totalWidth = gridWidth + 2 * sidePadding
        let totalHeight = gridHeight + topPadding + bottomPadding
        
        // Create the main view with optimal size
        view = NSView(frame: NSRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadBombStarsGame()
        
        // Update popover size to match initial view size
        if let popover = findPopover() {
            popover.contentSize = view.frame.size
        }
    }
    
    func showGameView() {
        currentMode = .game
        // Hide other views
        settingsViewController?.view.isHidden = true
        statisticsViewController?.view.isHidden = true
        aboutViewController?.view.isHidden = true
        // Show game view
        skView.isHidden = false
        
        // Update skView frame to match view bounds
        skView.frame = view.bounds
        
        // Update popover size and rerender game based on current difficulty
        if let gameScene = skView.scene as? GameScene {
            // Ensure game scene has current difficulty
            gameScene.difficulty = currentDifficulty
            let optimalSize = gameScene.calculateOptimalSize()
            resizeWindowToSize(optimalSize)
            
            // Force rerender by calling layoutGame after a brief delay to ensure window resize is complete
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let scene = self.skView.scene as? GameScene else { return }
                // Ensure difficulty is still set correctly
                scene.difficulty = self.currentDifficulty
                // Update scene size to match current view bounds
                scene.size = self.view.bounds.size
                // Update skView frame again to ensure it matches
                self.skView.frame = self.view.bounds
                // Recalculate cell size and layout the game
                scene.calculateCellSize()
                scene.layoutGame()
                // Reposition window under gamepad icon after rendering
                self.repositionWindowUnderGamepadIcon()
            }
        } else {
            // Fallback: if scene doesn't exist, create it with correct difficulty
            // This shouldn't normally happen, but handle it gracefully
            loadBombStarsGame()
            if let gameScene = skView.scene as? GameScene {
                gameScene.difficulty = currentDifficulty
                let optimalSize = gameScene.calculateOptimalSize()
                resizeWindowToSize(optimalSize)
                // Reposition window under gamepad icon
                DispatchQueue.main.async { [weak self] in
                    self?.repositionWindowUnderGamepadIcon()
                }
            }
        }
    }
    
    func showSettingsView() {
        currentMode = .settings
        
        if settingsViewController == nil {
            let settingsVC = SettingsViewController()
            settingsVC.delegate = self
            settingsVC.currentDifficulty = currentDifficulty
            addChild(settingsVC)
            view.addSubview(settingsVC.view)
            settingsVC.view.frame = view.bounds
            settingsVC.view.autoresizingMask = [.width, .height]
            settingsViewController = settingsVC
        } else {
            settingsViewController?.currentDifficulty = currentDifficulty
            settingsViewController?.updateButtonStates()
        }
        
        // Hide other views
        skView.isHidden = true
        statisticsViewController?.view.isHidden = true
        aboutViewController?.view.isHidden = true
        // Show settings view
        settingsViewController?.view.isHidden = false
        
        // Update popover size - use optimal game size for current difficulty
        // This ensures window is correctly sized when user changes difficulty in settings
        if let popover = findPopover() {
            if let gameScene = skView.scene as? GameScene {
                // Ensure game scene has current difficulty before calculating optimal size
                gameScene.difficulty = currentDifficulty
                let optimalSize = gameScene.calculateOptimalSize()
                resizeWindowToSize(optimalSize)
            } else {
                // Fallback to settings size if game scene not available
                if let settingsVC = settingsViewController {
                    let settingsSize = settingsVC.calculateOptimalSize()
                    resizeWindowToSize(settingsSize)
                }
            }
        }
        
        // Reposition window under gamepad icon after mode change
        DispatchQueue.main.async { [weak self] in
            self?.repositionWindowUnderGamepadIcon()
        }
    }
    
    func showStatisticsView() {
        currentMode = .statistics
        
        if statisticsViewController == nil {
            let statsVC = StatisticsViewController()
            statsVC.delegate = self
            addChild(statsVC)
            view.addSubview(statsVC.view)
            statsVC.view.frame = view.bounds
            statsVC.view.autoresizingMask = [.width, .height]
            statisticsViewController = statsVC
        }
        
        // Hide other views
        skView.isHidden = true
        settingsViewController?.view.isHidden = true
        aboutViewController?.view.isHidden = true
        // Show statistics view
        statisticsViewController?.view.isHidden = false
        statisticsViewController?.updateStatistics()
        
        // Update popover size - use optimal game size for current difficulty
        // This ensures window size matches the game mode size
        if let popover = findPopover() {
            if let gameScene = skView.scene as? GameScene {
                // Ensure game scene has current difficulty before calculating optimal size
                gameScene.difficulty = currentDifficulty
                let optimalSize = gameScene.calculateOptimalSize()
                resizeWindowToSize(optimalSize)
            } else {
                // Fallback: create a temporary scene to calculate size if scene not available
                let tempScene = GameScene(size: CGSize(width: 100, height: 100))
                tempScene.difficulty = currentDifficulty
                let optimalSize = tempScene.calculateOptimalSize()
                resizeWindowToSize(optimalSize)
            }
        }
        
        // Reposition window under gamepad icon after mode change
        DispatchQueue.main.async { [weak self] in
            self?.repositionWindowUnderGamepadIcon()
        }
    }
    
    func showAboutView() {
        currentMode = .about
        
        if aboutViewController == nil {
            let aboutVC = AboutViewController()
            aboutVC.delegate = self
            addChild(aboutVC)
            view.addSubview(aboutVC.view)
            aboutVC.view.frame = view.bounds
            aboutVC.view.autoresizingMask = [.width, .height]
            aboutViewController = aboutVC
        }
        
        // Hide other views
        skView.isHidden = true
        settingsViewController?.view.isHidden = true
        statisticsViewController?.view.isHidden = true
        // Show about view
        aboutViewController?.view.isHidden = false
        
        // Update popover size - use optimal game size for current difficulty
        // This ensures window size matches the game mode size
        if let popover = findPopover() {
            if let gameScene = skView.scene as? GameScene {
                // Ensure game scene has current difficulty before calculating optimal size
                gameScene.difficulty = currentDifficulty
                let optimalSize = gameScene.calculateOptimalSize()
                resizeWindowToSize(optimalSize)
            } else {
                // Fallback: create a temporary scene to calculate size if scene not available
                let tempScene = GameScene(size: CGSize(width: 100, height: 100))
                tempScene.difficulty = currentDifficulty
                let optimalSize = tempScene.calculateOptimalSize()
                resizeWindowToSize(optimalSize)
            }
        }
        
        // Reposition window under gamepad icon after mode change
        DispatchQueue.main.async { [weak self] in
            self?.repositionWindowUnderGamepadIcon()
        }
    }
    
    func setupUI() {
        // Create SKView to fill the entire view
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.width, .height]
        skView.allowsTransparency = false
        
        // Enable mouse tracking for hover effects
        let trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        view.addTrackingArea(trackingArea)
        
        view.addSubview(skView)
    }
    
    override func mouseMoved(with event: NSEvent) {
        // Forward mouse movement to the scene
        if let scene = skView.scene as? GameScene {
            // Get location in window coordinates
            let windowLocation = event.locationInWindow
            // Convert from window to SKView coordinates
            let skViewPoint = skView.convert(windowLocation, from: nil)
            // Convert to scene coordinates (SpriteKit uses bottom-left origin)
            let scenePoint = CGPoint(
                x: skViewPoint.x,
                y: skView.bounds.height - skViewPoint.y
            )
            
            // Create event with scene coordinates
            if let sceneEvent = NSEvent.mouseEvent(
                with: .mouseMoved,
                location: scenePoint,
                modifierFlags: event.modifierFlags,
                timestamp: event.timestamp,
                windowNumber: event.windowNumber,
                context: nil,
                eventNumber: event.eventNumber,
                clickCount: event.clickCount,
                pressure: event.pressure
            ) {
                scene.mouseMoved(with: sceneEvent)
            }
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        // Forward mouse exit to the scene
        if let scene = skView.scene as? GameScene {
            scene.mouseExited(with: event)
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        // Update scene size when view size changes
        // Only layout if cells array exists and matches grid size
        if let scene = skView.scene as? GameScene {
            scene.size = view.bounds.size
            // layoutGame() will check internally if cells array is valid
            scene.layoutGame()
        }
    }
    
    func loadBombStarsGame() {
        // Use the view's current size for the scene
        let sceneSize = view.bounds.size
        
        // Update skView frame to match view
        skView.frame = view.bounds
        
        // Create and present Bomb Stars game scene
        let scene = GameScene(size: sceneSize)
        scene.scaleMode = .resizeFill
        scene.gameSceneDelegate = self
        scene.difficulty = currentDifficulty
        scene.navigationDelegate = self
        skView.presentScene(scene)
    }
}

// Protocol for navigation from GameScene
protocol GameSceneNavigationDelegate: AnyObject {
    func gameSceneRequestSettings(_ scene: GameScene)
    func gameSceneRequestStatistics(_ scene: GameScene)
}

extension GameContainerViewController: GameSceneNavigationDelegate {
    func gameSceneRequestSettings(_ scene: GameScene) {
        showSettingsView()
    }
    
    func gameSceneRequestStatistics(_ scene: GameScene) {
        showStatisticsView()
    }
}
