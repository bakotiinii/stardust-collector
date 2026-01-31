//
//  GameScene.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import GameplayKit
import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameSceneDidChangeDifficulty(_ scene: GameScene, optimalSize: CGSize)
}

class GameScene: SKScene {
    // Delegate for window resizing
    weak var gameSceneDelegate: GameSceneDelegate?
    
    // Delegate for navigation
    weak var navigationDelegate: GameSceneNavigationDelegate?
    
    // Difficulty
    var difficulty: Difficulty = .easy
    
    // Game constants (computed from difficulty)
    var gridSize: Int { difficulty.gridSize }
    var cellSize: CGFloat = 25 // Will be calculated dynamically
    let gridSpacing: CGFloat = 2
    var totalStars: Int { difficulty.totalStars }
    var totalRocks: Int { difficulty.totalRocks }
    var maxBombs: Int { difficulty.maxBombs }
    
    // UI padding constants
    let topPadding: CGFloat = 80  // Space for status labels at top (small padding)
    let bottomPadding: CGFloat = 70  // Space for buttons at bottom (button height 36 + padding 20 + extra spacing)
    let sidePadding: CGFloat = 12  // Side padding
    let labelSpace: CGFloat = 20  // Space for row/column labels (part of game field)
    
    // Game state
    var cells: [[CellNode]] = []
    var starPositions: Set<GridPosition> = []
    var rockPositions: Set<GridPosition> = []
    var bombsPlaced = 0
    var starsCollected = 0
    var gameOver = false
    var gameWon = false
    var pendingBombs = 0 // Track bombs waiting to explode
    
    // UI elements
    var newGameButton: SKLabelNode?
    var restartGameButton: SKLabelNode?
    var settingsNavigationButton: SKLabelNode?
    var soundToggleButton: SKLabelNode?
    var statusLabel: SKLabelNode?
    var bombsLabel: SKLabelNode?
    var topGlassNode: SKEffectNode?
    var buttonGlassNode: SKEffectNode?
    var restartButtonGlassNode: SKEffectNode?
    
    // Grid labels (letters and numbers)
    var columnLabels: [SKLabelNode] = []
    var rowLabels: [SKLabelNode] = []
    
    // Hover state tracking
    var isNewGameHovered = false
    var isRestartGameHovered = false
    var isSettingsButtonHovered = false
    var isSoundButtonHovered = false
    
    // Track if statistics have been recorded for this game
    var statisticsRecorded = false
    
    class CellNode: SKShapeNode {
        var gridRow: Int = 0
        var gridCol: Int = 0
        var hasStar: Bool = false
        var hasRock: Bool = false
        var hasStarDust: Bool = false
        var isDestroyed: Bool = false
        var hasBomb: Bool = false
        var bombTimer: Timer?
    }
    
    override func didMove(to view: SKView) {
        applyColorScheme()
        calculateCellSize()
        setupUI()
        startNewGame()
        
        // Listen for color scheme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(colorSchemeDidChange),
            name: .colorSchemeDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func colorSchemeDidChange() {
        applyColorScheme()
        // Update all cells
        updateCellColors()
        // Update buttons
        updateButtonColors()
    }
    
    func applyColorScheme() {
        let scheme = ColorSchemeManager.shared.currentScheme
        backgroundColor = scheme.backgroundColor
    }
    
    func updateCellColors() {
        let scheme = ColorSchemeManager.shared.currentScheme
        for row in cells {
            for cell in row {
                if cell.isDestroyed {
                    cell.fillColor = scheme.destroyedCellFillColor
                    cell.strokeColor = scheme.destroyedCellStrokeColor
                } else {
                    cell.fillColor = scheme.cellFillColor
                    cell.strokeColor = scheme.cellStrokeColor
                }
            }
        }
    }
    
    func updateButtonColors() {
        let scheme = ColorSchemeManager.shared.currentScheme
        newGameButton?.fontColor = scheme.buttonTextColor
        restartGameButton?.fontColor = scheme.buttonTextColor
        settingsNavigationButton?.fontColor = scheme.buttonTextColor
        soundToggleButton?.fontColor = scheme.buttonTextColor
    }
    
    func updateSoundIcon() {
        // Update sound icon based on sound state
        if SoundManager.shared.isSoundEnabled {
            soundToggleButton?.text = "🔊"
        } else {
            soundToggleButton?.text = "🔇"
        }
    }
    
    func calculateCellSize() {
        // Calculate available space for the entire game field (including labels)
        // Labels are part of the field, so padding is applied to the label+grid block
        let availableWidth = size.width - 2 * sidePadding
        let availableHeight = size.height - topPadding - bottomPadding
        
        // Subtract label space from available space for the actual grid cells
        let gridAvailableWidth = availableWidth - labelSpace  // Left side: row labels
        let gridAvailableHeight = availableHeight - labelSpace  // Top: column labels
        
        // Calculate cell size based on available grid space
        let maxCellWidth = (gridAvailableWidth - CGFloat(gridSize - 1) * gridSpacing) / CGFloat(gridSize)
        let maxCellHeight = (gridAvailableHeight - CGFloat(gridSize - 1) * gridSpacing) / CGFloat(gridSize)
        
        // Use the smaller dimension to ensure grid fits
        cellSize = min(maxCellWidth, maxCellHeight)
        
        // Ensure minimum cell size
        cellSize = max(cellSize, 15)
    }
    
    func layoutGame() {
        // Recalculate cell size and reposition everything
        calculateCellSize()
        // Only layout if cells array matches current grid size
        if !cells.isEmpty && cells.count == gridSize && cells[0].count == gridSize {
            // Calculate total field size (grid + labels)
            let totalGridSize = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
            let totalFieldWidth = totalGridSize + labelSpace  // Grid + row labels on left
            let totalFieldHeight = totalGridSize + labelSpace  // Grid + column labels on top
            
            // Center the entire field (including labels) horizontally
            let fieldStartX = (size.width - totalFieldWidth) / 2
            // Position field from top (accounting for topPadding)
            let fieldStartY = size.height - topPadding - totalFieldHeight
            
            // Grid starts after label space
            let startX = fieldStartX + labelSpace
            let startY = fieldStartY + labelSpace
            
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    let cell = cells[row][col]
                // Update cell size with rounded corners
                let cornerRadius = cellSize * 0.15
                cell.path = CGPath(roundedRect: CGRect(x: -cellSize / 2, y: -cellSize / 2, width: cellSize, height: cellSize), 
                                   cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
                    
                    let x = startX + CGFloat(col) * (cellSize + gridSpacing) + cellSize / 2
                    let y = startY + CGFloat(gridSize - 1 - row) * (cellSize + gridSpacing) + cellSize / 2
                    cell.position = CGPoint(x: x, y: y)
                    
                    // Update positions of child nodes (icons)
                    updateChildNodePositions(for: cell, atRow: row, col: col)
                }
            }
            
            // Update UI positions
            updateUIPositions()
            
            // Update grid labels
            updateGridLabels()
        }
    }
    
    func updateChildNodePositions(for cell: CellNode, atRow row: Int, col: Int) {
        // Update positions of all child nodes (bombs, rocks, stars, etc.)
        if let bombIcon = childNode(withName: "bomb_\(row)_\(col)") {
            bombIcon.position = cell.position
        }
        if let rockIcon = childNode(withName: "rock_\(row)_\(col)") {
            rockIcon.position = cell.position
        }
        if let starIcon = childNode(withName: "collected_star_\(row)_\(col)") {
            starIcon.position = cell.position
        }
        if let revealedStarIcon = childNode(withName: "revealed_star_\(row)_\(col)") {
            revealedStarIcon.position = cell.position
        }
        if let starDustIcon = childNode(withName: "stardust_\(row)_\(col)") {
            starDustIcon.position = cell.position
        }
    }
    
    func updateUIPositions() {
        // Update top glass background
        let topGlassHeight: CGFloat = 100
        topGlassNode?.position = CGPoint(x: size.width / 2, y: size.height - topGlassHeight / 2)
        
        // Update labels
        statusLabel?.position = CGPoint(x: size.width / 2, y: size.height - 50)
        bombsLabel?.position = CGPoint(x: size.width / 2, y: size.height - 70)
        
        // Update navigation button (right corner)
        let iconButtonSize: CGFloat = 20
        let iconPadding: CGFloat = 12
        let iconSpacing: CGFloat = 8  // Space between icons
        let iconY = size.height - 30
        
        // Settings icon (rightmost)
        let settingsX = size.width - iconPadding - iconButtonSize / 2
        settingsNavigationButton?.position = CGPoint(x: settingsX, y: iconY)
        
        // Sound toggle icon (left of settings icon)
        let soundX = settingsX - iconButtonSize - iconSpacing
        soundToggleButton?.position = CGPoint(x: soundX, y: iconY)
        
        // Update buttons and their glass backgrounds - positioned at bottom left and right
        let buttonWidth: CGFloat = 140
        let buttonHeight: CGFloat = 36
        let sidePadding: CGFloat = 12
        let bottomPadding: CGFloat = 12  // Distance from bottom edge
        
        let buttonY = bottomPadding + buttonHeight / 2
        
        // New Game button position (left side)
        let newGameX = sidePadding + buttonWidth / 2
        buttonGlassNode?.position = CGPoint(x: newGameX, y: buttonY)
        newGameButton?.position = CGPoint(x: newGameX, y: buttonY - 2)
        
        // Restart Game button position (right side)
        let restartX = size.width - sidePadding - buttonWidth / 2
        restartButtonGlassNode?.position = CGPoint(x: restartX, y: buttonY)
        restartGameButton?.position = CGPoint(x: restartX, y: buttonY - 2)
    }
    
    func setupUI() {
        // Create frosted glass background for top status area
        let topGlassHeight: CGFloat = 100
        topGlassNode = createFrostedGlassNode(width: size.width, height: topGlassHeight)
        topGlassNode?.position = CGPoint(x: size.width / 2, y: size.height - topGlassHeight / 2)
        topGlassNode?.zPosition = 99
        addChild(topGlassNode!)
        
        // Navigation button (right corner)
        let iconButtonSize: CGFloat = 20
        let iconPadding: CGFloat = 12
        let iconSpacing: CGFloat = 8  // Space between icons
        let iconY = size.height - 30
        
        // Settings icon (rightmost) - flat, no effects
        let settingsX = size.width - iconPadding - iconButtonSize / 2
        settingsNavigationButton = SKLabelNode(fontNamed: ".SF Pro Display Semibold")
        if settingsNavigationButton?.fontName == nil {
            settingsNavigationButton = SKLabelNode(fontNamed: "HelveticaNeue-Medium")
        }
        settingsNavigationButton?.text = "⚙️"
        settingsNavigationButton?.fontSize = 12
        settingsNavigationButton?.position = CGPoint(x: settingsX, y: iconY)
        settingsNavigationButton?.zPosition = 101
        addChild(settingsNavigationButton!)
        
        // Sound toggle icon (left of settings icon)
        let soundX = settingsX - iconButtonSize - iconSpacing
        soundToggleButton = SKLabelNode(fontNamed: ".SF Pro Display Semibold")
        if soundToggleButton?.fontName == nil {
            soundToggleButton = SKLabelNode(fontNamed: "HelveticaNeue-Medium")
        }
        soundToggleButton?.fontSize = 12
        soundToggleButton?.position = CGPoint(x: soundX, y: iconY)
        soundToggleButton?.zPosition = 101
        updateSoundIcon()  // Set initial icon based on sound state
        addChild(soundToggleButton!)
        
        // Apply color scheme to buttons (will be set by updateButtonColors)
        
        // Status label with modern typography
        statusLabel = SKLabelNode(fontNamed: ".SF Pro Display Semibold")
        if statusLabel?.fontName == nil {
            statusLabel = SKLabelNode(fontNamed: "HelveticaNeue-Medium")
        }
        statusLabel?.text = "Place bombs to find stars!"
        statusLabel?.fontSize = 17
        if #available(macOS 10.14, *) {
            statusLabel?.fontColor = NSColor.labelColor
        } else {
            statusLabel?.fontColor = NSColor.black
        }
        statusLabel?.position = CGPoint(x: size.width / 2, y: size.height - 50)
        statusLabel?.zPosition = 101
        addChild(statusLabel!)
        
        // Bombs label
        bombsLabel = SKLabelNode(fontNamed: ".SF Pro Display Regular")
        if bombsLabel?.fontName == nil {
            bombsLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        }
        bombsLabel?.text = "Bombs: 8/8"
        bombsLabel?.fontSize = 15
        if #available(macOS 10.14, *) {
            bombsLabel?.fontColor = NSColor.secondaryLabelColor
        } else {
            bombsLabel?.fontColor = NSColor.darkGray
        }
        bombsLabel?.position = CGPoint(x: size.width / 2, y: size.height - 70)
        bombsLabel?.zPosition = 101
        addChild(bombsLabel!)
        
        // New game and restart buttons with liquid glass effect - positioned at bottom left and right
        let buttonWidth: CGFloat = 140
        let buttonHeight: CGFloat = 36
        let sidePadding: CGFloat = 12
        let bottomPadding: CGFloat = 12  // Distance from bottom edge
        
        let buttonY = bottomPadding + buttonHeight / 2
        
        // New Game button (left side)
        let newGameX = sidePadding + buttonWidth / 2
        buttonGlassNode = createFrostedGlassNode(width: buttonWidth, height: buttonHeight, cornerRadius: 18)
        buttonGlassNode?.position = CGPoint(x: newGameX, y: buttonY)
        buttonGlassNode?.zPosition = 99
        addChild(buttonGlassNode!)
        
        newGameButton = SKLabelNode(fontNamed: ".SF Pro Display Semibold")
        if newGameButton?.fontName == nil {
            newGameButton = SKLabelNode(fontNamed: "HelveticaNeue-Medium")
        }
        newGameButton?.text = "New Game"
        newGameButton?.fontSize = 16
        // Lower text position inside bubble (move down by 2 pixels)
        newGameButton?.position = CGPoint(x: newGameX, y: buttonY - 2)
        newGameButton?.zPosition = 101
        addChild(newGameButton!)
        
        // Restart Game button (right side)
        let restartX = size.width - sidePadding - buttonWidth / 2
        restartButtonGlassNode = createFrostedGlassNode(width: buttonWidth, height: buttonHeight, cornerRadius: 18)
        restartButtonGlassNode?.position = CGPoint(x: restartX, y: buttonY)
        restartButtonGlassNode?.zPosition = 99
        addChild(restartButtonGlassNode!)
        
        restartGameButton = SKLabelNode(fontNamed: ".SF Pro Display Semibold")
        if restartGameButton?.fontName == nil {
            restartGameButton = SKLabelNode(fontNamed: "HelveticaNeue-Medium")
        }
        restartGameButton?.text = "Restart Game"
        restartGameButton?.fontSize = 16
        
        // Apply color scheme to buttons
        updateButtonColors()
        // Lower text position inside bubble (move down by 2 pixels)
        restartGameButton?.position = CGPoint(x: restartX, y: buttonY - 2)
        restartGameButton?.zPosition = 101
        addChild(restartGameButton!)
    }
    
    func createFrostedGlassNode(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 0) -> SKEffectNode {
        let glassNode = SKEffectNode()
        
        // Create shape with rounded corners - Apple liquid glass style
        let shape = SKShapeNode(rect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerRadius: cornerRadius)
        
        // Remove white glow - transparent background with no blur or stroke
        shape.fillColor = NSColor.clear
        shape.strokeColor = NSColor.clear
        shape.lineWidth = 0
        
        glassNode.addChild(shape)
        
        // Remove blur filter to eliminate white glow
        glassNode.shouldEnableEffects = false
        
        return glassNode
    }
    
    func createFrostedGlassNodeWithBorder(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 0) -> SKEffectNode {
        let glassNode = SKEffectNode()
        
        // Create shape with rounded corners - Apple liquid glass style
        let shape = SKShapeNode(rect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerRadius: cornerRadius)
        
        // Remove white glow - transparent background with no blur
        shape.fillColor = NSColor.clear
        // Visible border around icons (keep border but remove glow)
        shape.strokeColor = NSColor.gray.withAlphaComponent(0.8)
        shape.lineWidth = 1.5
        
        glassNode.addChild(shape)
        
        // Remove blur filter to eliminate white glow
        glassNode.shouldEnableEffects = false
        
        return glassNode
    }
    
    func startNewGame() {
        // Reset game state
        removeAllChildren()
        cells.removeAll()
        starPositions.removeAll()
        rockPositions.removeAll()
        bombsPlaced = 0
        starsCollected = 0
        gameOver = false
        gameWon = false
        pendingBombs = 0
        statisticsRecorded = false
        
        // Re-add UI
        setupUI()
        
        // Create grid
        createGrid()
        
        // Place rocks first
        placeRocks()
        
        // Place stars (avoiding rocks)
        placeStars()
        
        updateUI()
    }
    
    func restartGame() {
        // Save current star and rock positions
        let savedStarPositions = starPositions
        let savedRockPositions = rockPositions
        
        // Reset game state but keep UI
        cells.removeAll()
        bombsPlaced = 0
        starsCollected = 0
        gameOver = false
        gameWon = false
        pendingBombs = 0
        statisticsRecorded = false
        
        // Remove all game-related child nodes (bombs, stars, rocks, etc.) but keep UI
        let nodesToRemove = children.filter { node in
            if let name = node.name {
                return name.hasPrefix("bomb_") || 
                       name.hasPrefix("rock_") || 
                       name.hasPrefix("collected_star_") || 
                       name.hasPrefix("revealed_star_") || 
                       name.hasPrefix("stardust_")
            }
            return node is CellNode
        }
        nodesToRemove.forEach { $0.removeFromParent() }
        
        // Restore saved positions
        starPositions = savedStarPositions
        rockPositions = savedRockPositions
        
        // Create grid
        createGrid()
        
        // Restore rocks at saved positions (only if they're within bounds)
        for position in savedRockPositions {
            guard position.row >= 0 && position.row < gridSize && 
                  position.col >= 0 && position.col < gridSize &&
                  position.row < cells.count &&
                  position.col < cells[position.row].count else { continue }
            cells[position.row][position.col].hasRock = true
            
            // Add rock icon
            let rockLabel = SKLabelNode(text: "🪨")
            rockLabel.fontSize = 18
            rockLabel.position = CGPoint(x: cells[position.row][position.col].position.x, y: cells[position.row][position.col].position.y)
            rockLabel.verticalAlignmentMode = .center
            rockLabel.horizontalAlignmentMode = .center
            rockLabel.zPosition = 5
            rockLabel.name = "rock_\(position.row)_\(position.col)"
            addChild(rockLabel)
        }
        
        // Restore stars at saved positions (only if they're within bounds)
        for position in savedStarPositions {
            guard position.row >= 0 && position.row < gridSize && 
                  position.col >= 0 && position.col < gridSize &&
                  position.row < cells.count &&
                  position.col < cells[position.row].count else { continue }
            cells[position.row][position.col].hasStar = true
            
            // Add star dust around the star
            addStarDustAroundStar(atRow: position.row, col: position.col)
        }
        
        updateUI()
    }
    
    func createGrid() {
        // Calculate total field size (grid + labels)
        let totalGridSize = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let totalFieldWidth = totalGridSize + labelSpace  // Grid + row labels on left
        let totalFieldHeight = totalGridSize + labelSpace  // Grid + column labels on top
        
        // Center the entire field (including labels) horizontally
        let fieldStartX = (size.width - totalFieldWidth) / 2
        // Position field from top (accounting for topPadding)
        let fieldStartY = size.height - topPadding - totalFieldHeight
        
        // Grid starts after label space
        let startX = fieldStartX + labelSpace
        let startY = fieldStartY + labelSpace
        
        cells = []
        
        for row in 0..<gridSize {
            var rowCells: [CellNode] = []
            for col in 0..<gridSize {
                // Create rounded rectangle cell with liquid glass effect
                let cornerRadius = cellSize * 0.15
                let cell = CellNode(rectOf: CGSize(width: cellSize, height: cellSize), cornerRadius: cornerRadius)
                cell.gridRow = row
                cell.gridCol = col
                
                // Use color scheme colors
                let scheme = ColorSchemeManager.shared.currentScheme
                cell.fillColor = scheme.cellFillColor
                cell.strokeColor = scheme.cellStrokeColor
                cell.lineWidth = 0.5
                
                let x = startX + CGFloat(col) * (cellSize + gridSpacing) + cellSize / 2
                let y = startY + CGFloat(gridSize - 1 - row) * (cellSize + gridSpacing) + cellSize / 2
                cell.position = CGPoint(x: x, y: y)
                
                rowCells.append(cell)
                addChild(cell)
            }
            cells.append(rowCells)
        }
        
        // Create grid labels (letters and numbers)
        createGridLabels()
    }
    
    func createGridLabels() {
        // Remove existing labels
        columnLabels.forEach { $0.removeFromParent() }
        rowLabels.forEach { $0.removeFromParent() }
        columnLabels.removeAll()
        rowLabels.removeAll()
        
        // Calculate total field size (grid + labels)
        let totalGridSize = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let totalFieldWidth = totalGridSize + labelSpace
        let totalFieldHeight = totalGridSize + labelSpace
        
        // Center the entire field (including labels) horizontally
        let fieldStartX = (size.width - totalFieldWidth) / 2
        // Position field from top (accounting for topPadding)
        let fieldStartY = size.height - topPadding - totalFieldHeight
        
        // Grid starts after label space
        let startX = fieldStartX + labelSpace
        let startY = fieldStartY + labelSpace
        
        // Create column labels (letters A, B, C, ...) at the top
        for col in 0..<gridSize {
            let letter = String(Character(UnicodeScalar(65 + col)!)) // A=65, B=66, etc.
            let label = SKLabelNode(fontNamed: ".SF Pro Display Regular")
            if label.fontName == nil {
                label.fontName = "HelveticaNeue"
            }
            label.text = letter
            label.fontSize = 14
            if #available(macOS 10.14, *) {
                label.fontColor = NSColor.secondaryLabelColor
            } else {
                label.fontColor = NSColor.darkGray
            }
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            
            // Position above the grid (in the label space area)
            let x = startX + CGFloat(col) * (cellSize + gridSpacing) + cellSize / 2
            let y = fieldStartY + labelSpace / 2  // Center in the label space area
            label.position = CGPoint(x: x, y: y)
            label.zPosition = 100
            
            columnLabels.append(label)
            addChild(label)
        }
        
        // Create row labels (numbers 1, 2, 3, ...) on the left, from bottom to top
        for row in 0..<gridSize {
            let number = String(gridSize - row) // Top row = gridSize, bottom row = 1
            let label = SKLabelNode(fontNamed: ".SF Pro Display Regular")
            if label.fontName == nil {
                label.fontName = "HelveticaNeue"
            }
            label.text = number
            label.fontSize = 14
            if #available(macOS 10.14, *) {
                label.fontColor = NSColor.secondaryLabelColor
            } else {
                label.fontColor = NSColor.darkGray
            }
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            
            // Position to the left of the grid (in the label space area)
            let x = fieldStartX + labelSpace / 2  // Center in the label space area
            let y = startY + CGFloat(gridSize - 1 - row) * (cellSize + gridSpacing) + cellSize / 2
            label.position = CGPoint(x: x, y: y)
            label.zPosition = 100
            
            rowLabels.append(label)
            addChild(label)
        }
    }
    
    func updateGridLabels() {
        // Calculate total field size (grid + labels)
        let totalGridSize = CGFloat(gridSize) * (cellSize + gridSpacing) - gridSpacing
        let totalFieldWidth = totalGridSize + labelSpace
        let totalFieldHeight = totalGridSize + labelSpace
        
        // Center the entire field (including labels) horizontally
        let fieldStartX = (size.width - totalFieldWidth) / 2
        // Position field from top (accounting for topPadding)
        let fieldStartY = size.height - topPadding - totalFieldHeight
        
        // Grid starts after label space
        let startX = fieldStartX + labelSpace
        let startY = fieldStartY + labelSpace
        
        // Update column labels (letters)
        for (index, label) in columnLabels.enumerated() {
            guard index < gridSize else { break }
            let x = startX + CGFloat(index) * (cellSize + gridSpacing) + cellSize / 2
            let y = fieldStartY + labelSpace / 2  // Center in the label space area
            label.position = CGPoint(x: x, y: y)
        }
        
        // Update row labels (numbers)
        for (index, label) in rowLabels.enumerated() {
            guard index < gridSize else { break }
            let x = fieldStartX + labelSpace / 2  // Center in the label space area
            let y = startY + CGFloat(gridSize - 1 - index) * (cellSize + gridSpacing) + cellSize / 2
            label.position = CGPoint(x: x, y: y)
        }
    }
    
    func placeRocks() {
        var attempts = 0
        let maxAttempts = 1000
        
        while rockPositions.count < totalRocks && attempts < maxAttempts {
            let row = Int.random(in: 0..<gridSize)
            let col = Int.random(in: 0..<gridSize)
            let position = GridPosition(row: row, col: col)
            
            // Check if position is valid (not in neighboring cells and not already a rock)
            let isValid = rockPositions.allSatisfy { existingPos in
                let rowDiff = abs(existingPos.row - row)
                let colDiff = abs(existingPos.col - col)
                return !(rowDiff <= 1 && colDiff <= 1)
            }
            
            guard isValid else {
                attempts += 1
                continue
            }
            
            rockPositions.insert(position)
            cells[row][col].hasRock = true
            
            // Add rock icon
            let rockLabel = SKLabelNode(text: "🪨")
            rockLabel.fontSize = 18
            rockLabel.position = CGPoint(x: cells[row][col].position.x, y: cells[row][col].position.y)
            rockLabel.verticalAlignmentMode = .center
            rockLabel.horizontalAlignmentMode = .center
            rockLabel.zPosition = 5
            rockLabel.name = "rock_\(row)_\(col)"
            addChild(rockLabel)
            
            attempts += 1
        }
    }
    
    func placeStars() {
        var attempts = 0
        let maxAttempts = 1000
        
        while starPositions.count < totalStars && attempts < maxAttempts {
            let row = Int.random(in: 0..<gridSize)
            let col = Int.random(in: 0..<gridSize)
            let position = GridPosition(row: row, col: col)
            
            // Check if position is valid (not in neighboring cells, not a rock)
            // Cannot place star on rock
            guard !cells[row][col].hasRock else {
                attempts += 1
                continue
            }
            
            // Check distance from other stars
            let isValid = starPositions.allSatisfy { existingPos in
                let rowDiff = abs(existingPos.row - row)
                let colDiff = abs(existingPos.col - col)
                return !(rowDiff <= 1 && colDiff <= 1)
            }
            
            guard isValid else {
                attempts += 1
                continue
            }
            
            starPositions.insert(position)
            cells[row][col].hasStar = true
            
            // Add star dust to cells around the star (one cell in any direction)
            addStarDustAroundStar(atRow: row, col: col)
            
            attempts += 1
        }
    }
    
    func addStarDustAroundStar(atRow row: Int, col: Int) {
        // Add star dust to all 8 surrounding cells (one cell in any direction)
        let directions = [
            (-1, -1), (-1, 0), (-1, 1), // top row
            (0, -1), (0, 1),  // middle row (skip center - it has the star)
            (1, -1), (1, 0), (1, 1)   // bottom row
        ]
        
        for (dr, dc) in directions {
            let newRow = row + dr
            let newCol = col + dc
            
            // Check bounds - verify both gridSize and cells array dimensions
            if newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize &&
               newRow < cells.count && newCol < cells[newRow].count {
                let cell = cells[newRow][newCol]
                // Don't add star dust to rocks or cells that already have stars
                if !cell.hasRock && !cell.hasStar {
                    cell.hasStarDust = true
                }
            }
        }
    }
    
    func placeBomb(at cell: CellNode) {
        guard !gameOver && !gameWon else { return }
        guard bombsPlaced < maxBombs else {
            return // Can't place more bombs
        }
        guard pendingBombs == 0 else {
            return // Can't place another bomb until current one explodes
        }
        guard !cell.isDestroyed && !cell.hasBomb && !cell.hasRock else { return }
        
        cell.hasBomb = true
        cell.fillColor = NSColor.red.withAlphaComponent(0.3)
        
        // Add bomb icon - centered in cell
        let bombLabel = SKLabelNode(text: "💣")
        bombLabel.fontSize = 18
        bombLabel.position = CGPoint(x: cell.position.x, y: cell.position.y)
        bombLabel.verticalAlignmentMode = .center
        bombLabel.horizontalAlignmentMode = .center
        bombLabel.zPosition = 10
        bombLabel.name = "bomb_\(cell.gridRow)_\(cell.gridCol)"
        addChild(bombLabel)
        
        bombsPlaced += 1
        pendingBombs += 1
        updateUI()
        
        // Play plant bomb sound
        SoundManager.shared.playPlantBombSound(onNode: self)
        
        // Explode after 2 seconds using async/await
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            self?.explodeBomb(at: cell)
        }
    }
    
    func explodeBomb(at cell: CellNode) {
        guard cell.hasBomb else { return }
        
        let row = cell.gridRow
        let col = cell.gridCol
        
        // Remove bomb icon first
        if let bombIcon = childNode(withName: "bomb_\(cell.gridRow)_\(cell.gridCol)") {
            bombIcon.removeFromParent()
        }
        
        cell.hasBomb = false
        
        // Play blow bomb sound
        SoundManager.shared.playBlowBombSound(onNode: self)
        
        // Destroy center cell first (if not a rock)
        if !cell.hasRock {
            destroyCell(cell, atRow: row, col: col)
        }
        
        // Cross pattern: destroy cells sequentially in each direction
        // Each direction: up (2), left (2), right (2), down (2)
        // Stop at rock cells - rocks block further blasts in that direction
        let directions: [(name: String, offsets: [(dr: Int, dc: Int)])] = [
            ("up", [(-1, 0), (-2, 0)]),
            ("left", [(0, -1), (0, -2)]),
            ("right", [(0, 1), (0, 2)]),
            ("down", [(1, 0), (2, 0)])
        ]
        
        var baseDelay = 0.0
        var directionsCompleted = 0
        
        for direction in directions {
            let directionStartDelay = baseDelay
            processDirection(
                fromRow: row,
                fromCol: col,
                offsets: direction.offsets,
                startDelay: directionStartDelay
            )                { [weak self] in
                    guard let self = self else { return }
                    directionsCompleted += 1
                    if directionsCompleted == directions.count {
                        Task { @MainActor [weak self] in
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                            self?.checkGameState()
                        }
                    }
                }
            baseDelay += Double(direction.offsets.count) * 0.1
        }
        
        pendingBombs -= 1
    }
    
    func processDirection(fromRow row: Int, fromCol col: Int, offsets: [(dr: Int, dc: Int)], startDelay: Double, onComplete: @escaping () -> Void) {
        processDirectionRecursive(
            fromRow: row,
            fromCol: col,
            offsets: offsets,
            currentIndex: 0,
            delay: startDelay,
            onComplete: onComplete
        )
    }
    
    func processDirectionRecursive(fromRow row: Int, fromCol col: Int, offsets: [(dr: Int, dc: Int)], currentIndex: Int, delay: Double, onComplete: @escaping () -> Void) {
        // If we've processed all offsets in this direction, we're done
        guard currentIndex < offsets.count else {
            onComplete()
            return
        }
        
        let offset = offsets[currentIndex]
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard let self = self else {
                onComplete()
                return
            }
            
            let newRow = row + offset.dr
            let newCol = col + offset.dc
            
            // Check bounds - verify both gridSize and cells array dimensions
            guard newRow >= 0 && newRow < self.gridSize && 
                  newCol >= 0 && newCol < self.gridSize &&
                  newRow < self.cells.count &&
                  newCol < self.cells[newRow].count else {
                // Out of bounds - stop this direction
                onComplete()
                return
            }
            
            let targetCell = self.cells[newRow][newCol]
            
            // Stop explosion in this direction if we hit a rock
            // Rock blocks further blasts in this direction
            if targetCell.hasRock {
                // Don't destroy rock or cells beyond it - stop this direction
                onComplete()
                return
            }
            
            // Destroy the cell
            self.destroyCell(targetCell, atRow: newRow, col: newCol)
            
            // Process next cell in this direction
            self.processDirectionRecursive(
                fromRow: row,
                fromCol: col,
                offsets: offsets,
                currentIndex: currentIndex + 1,
                delay: 0.1, // 0.1 second delay between cells
                onComplete: onComplete
            )
        }
    }
    
    func destroyCell(_ cell: CellNode, atRow row: Int, col: Int) {
        guard !cell.isDestroyed && !cell.hasRock else { return } // Rocks cannot be destroyed
        
        cell.isDestroyed = true
        // Use color scheme for destroyed cells
        let scheme = ColorSchemeManager.shared.currentScheme
        cell.fillColor = scheme.destroyedCellFillColor
        cell.strokeColor = scheme.destroyedCellStrokeColor
        
        // Check if star was collected
        if cell.hasStar {
            starsCollected += 1
            
            // Play find star sound
            SoundManager.shared.playFindStarSound(onNode: self)
            
            // Show grey star indicator that stays visible
            let greyStarLabel = SKLabelNode(text: "⭐")
            greyStarLabel.fontSize = 20
            greyStarLabel.position = CGPoint(x: cell.position.x, y: cell.position.y)
            greyStarLabel.verticalAlignmentMode = .center
            greyStarLabel.horizontalAlignmentMode = .center
            greyStarLabel.zPosition = 50
            greyStarLabel.fontColor = NSColor.gray
            greyStarLabel.name = "collected_star_\(row)_\(col)"
            addChild(greyStarLabel)
            
            // Show brief animation of bright star, then replace with grey star
            let brightStarLabel = SKLabelNode(text: "⭐")
            brightStarLabel.fontSize = 20
            brightStarLabel.position = CGPoint(x: cell.position.x, y: cell.position.y)
            brightStarLabel.verticalAlignmentMode = .center
            brightStarLabel.horizontalAlignmentMode = .center
            brightStarLabel.zPosition = 51
            addChild(brightStarLabel)
            
            // Animate bright star fading out, then remove it (grey star stays)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            brightStarLabel.run(SKAction.sequence([fadeOut, remove]))
        }
        
        // Show star dust if cell has star dust (indicates star is nearby)
        if cell.hasStarDust {
            let starDustLabel = SKLabelNode(text: "✨")
            starDustLabel.fontSize = 16
            starDustLabel.position = CGPoint(x: cell.position.x, y: cell.position.y)
            starDustLabel.verticalAlignmentMode = .center
            starDustLabel.horizontalAlignmentMode = .center
            starDustLabel.zPosition = 45
            starDustLabel.name = "stardust_\(row)_\(col)"
            addChild(starDustLabel)
            
            // Keep star dust visible (don't fade out)
        }
    }
    
    func checkGameState() {
        // Check win condition
        if starsCollected >= totalStars {
            gameWon = true
            statusLabel?.text = "You Win! All stars collected!"
            statusLabel?.fontColor = NSColor.systemGreen
            
            // Play won sound
            SoundManager.shared.playWonSound(onNode: self)
            
            // Record statistics (only once per game)
            if !statisticsRecorded {
                StatisticsManager.shared.recordGame(won: true, difficulty: difficulty)
                statisticsRecorded = true
            }
            
            // Auto-restart after 5 seconds using async/await
            Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                self?.startNewGame()
            }
        } else if bombsPlaced >= maxBombs && pendingBombs == 0 {
            // All bombs placed and all have exploded - check if game is lost
            if starsCollected < totalStars {
                gameOver = true
                statusLabel?.text = "Game Over! Stars remaining: \(totalStars - starsCollected)"
                statusLabel?.fontColor = NSColor.systemRed
                
                // Play lose sound
                SoundManager.shared.playLoseSound(onNode: self)
                
                // Record statistics (only once per game)
                if !statisticsRecorded {
                    StatisticsManager.shared.recordGame(won: false, difficulty: difficulty)
                    statisticsRecorded = true
                }
                
                // Show all stars for 5 seconds then restart
                showAllStarsAndRestart()
            }
        }
        
        updateUI()
    }
    
    func showAllStarsAndRestart() {
        // Show all remaining stars
        for position in starPositions {
            // Check bounds - verify both gridSize and cells array dimensions
            guard position.row >= 0 && position.row < gridSize && 
                  position.col >= 0 && position.col < gridSize &&
                  position.row < cells.count &&
                  position.col < cells[position.row].count else {
                continue
            }
            let cell = cells[position.row][position.col]
            if !cell.isDestroyed && cell.hasStar {
                // Show star indicator
                let starLabel = SKLabelNode(text: "⭐")
                starLabel.fontSize = 20
                starLabel.position = CGPoint(x: cell.position.x, y: cell.position.y)
                starLabel.verticalAlignmentMode = .center
                starLabel.horizontalAlignmentMode = .center
                starLabel.zPosition = 50
                starLabel.name = "revealed_star_\(position.row)_\(position.col)"
                addChild(starLabel)
            }
        }
        
        // Auto-restart after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.startNewGame()
        }
    }
    
    func updateUI() {
        bombsLabel?.text = "Bombs: \(bombsPlaced)/\(maxBombs)"
        
        switch (gameWon, gameOver) {
        case (true, _):
            statusLabel?.text = "You Win! All stars collected!"
            statusLabel?.fontColor = .green
        case (_, true):
            statusLabel?.text = "Game Over! Stars remaining: \(totalStars - starsCollected)"
            statusLabel?.fontColor = .red
        default:
            statusLabel?.text = "Stars collected: \(starsCollected)/\(totalStars)"
            statusLabel?.fontColor = .black
        }
    }
    
    func calculateOptimalSize() -> CGSize {
        // Calculate optimal window size based on grid size
        // We want cells to be at least 25 pixels, with some padding
        let minCellSize: CGFloat = 25
        let gridSpacing: CGFloat = 2
        
        // Calculate grid dimensions
        let gridWidth = CGFloat(gridSize) * minCellSize + CGFloat(gridSize - 1) * gridSpacing
        let gridHeight = CGFloat(gridSize) * minCellSize + CGFloat(gridSize - 1) * gridSpacing
        
        // Add label space (labels are part of the field)
        let fieldWidth = gridWidth + labelSpace  // Grid + row labels
        let fieldHeight = gridHeight + labelSpace  // Grid + column labels
        
        // Add padding (padding applies to the entire field including labels)
        let totalWidth = fieldWidth + 2 * sidePadding
        let totalHeight = fieldHeight + topPadding + bottomPadding
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func restartGameAfterResize() {
        // This is called after window resize is complete
        startNewGame()
    }
    
    func isPointInButton(point: CGPoint, button: SKLabelNode?, glassNode: SKEffectNode?, buttonWidth: CGFloat = 140, buttonHeight: CGFloat = 36) -> Bool {
        guard let button = button else { return false }
        
        // Check if point is in button label
        if button.contains(point) {
            return true
        }
        
        // Check if point is in glass background (expanded hit area)
        if let glass = glassNode {
            let glassRect = CGRect(
                x: glass.position.x - buttonWidth / 2,
                y: glass.position.y - buttonHeight / 2,
                width: buttonWidth,
                height: buttonHeight
            )
            if glassRect.contains(point) {
                return true
            }
        }
        
        return false
    }
    
    func animateButtonClick(glassNode: SKEffectNode?, labelNode: SKLabelNode?, completion: @escaping () -> Void) {
        guard let glass = glassNode, let label = labelNode else {
            completion()
            return
        }
        
        // Scale down animation
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        
        glass.run(SKAction.sequence([scaleDown, scaleUp])) {
            completion()
        }
        label.run(SKAction.sequence([scaleDown, scaleUp]))
    }
    
    func updateButtonHover(button: SKLabelNode?, glassNode: SKEffectNode?, isHovered: Bool, currentHoverState: inout Bool) {
        guard let glass = glassNode, let label = button else { return }
        
        if isHovered != currentHoverState {
            currentHoverState = isHovered
            
            let scheme = ColorSchemeManager.shared.currentScheme
            if isHovered {
                // Hover effect: slightly scale up and brighten
                let scaleUp = SKAction.scale(to: 1.05, duration: 0.15)
                glass.run(scaleUp)
                label.run(scaleUp)
                
                // Brighten the text color using scheme hover color
                label.fontColor = scheme.buttonHoverColor
            } else {
                // Return to normal
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
                glass.run(scaleDown)
                label.run(scaleDown)
                
                // Restore original text color using scheme
                label.fontColor = scheme.buttonTextColor
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        
        // Check if sound toggle button was clicked
        if let soundButton = soundToggleButton, soundButton.contains(location) {
            SoundManager.shared.toggleSound()
            updateSoundIcon()
            return
        }
        
        // Check if settings navigation button was clicked
        if let settingsButton = settingsNavigationButton, settingsButton.contains(location) {
            navigationDelegate?.gameSceneRequestSettings(self)
            return
        }
        
        // Check if new game button was clicked
        if isPointInButton(point: location, button: newGameButton, glassNode: buttonGlassNode) {
            animateButtonClick(glassNode: buttonGlassNode, labelNode: newGameButton) { [weak self] in
                self?.startNewGame()
            }
            return
        }
        
        // Check if restart game button was clicked
        if isPointInButton(point: location, button: restartGameButton, glassNode: restartButtonGlassNode) {
            animateButtonClick(glassNode: restartButtonGlassNode, labelNode: restartGameButton) { [weak self] in
                self?.restartGame()
            }
            return
        }
        
        // Check if a cell was clicked
        for row in cells {
            for cell in row {
                if cell.contains(location) && !cell.isDestroyed && !cell.hasBomb {
                    placeBomb(at: cell)
                    return
                }
            }
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        let location = event.location(in: self)
        
        // Check hover state for Sound toggle button
        let soundHovered = soundToggleButton?.contains(location) ?? false
        if soundHovered != isSoundButtonHovered {
            isSoundButtonHovered = soundHovered
            let scheme = ColorSchemeManager.shared.currentScheme
            if soundHovered {
                soundToggleButton?.fontColor = scheme.buttonHoverColor
            } else {
                soundToggleButton?.fontColor = scheme.buttonTextColor
            }
        }
        
        // Check hover state for Settings navigation button
        let settingsHovered = settingsNavigationButton?.contains(location) ?? false
        if settingsHovered != isSettingsButtonHovered {
            isSettingsButtonHovered = settingsHovered
            let scheme = ColorSchemeManager.shared.currentScheme
            if settingsHovered {
                settingsNavigationButton?.fontColor = scheme.buttonHoverColor
            } else {
                settingsNavigationButton?.fontColor = scheme.buttonTextColor
            }
        }
        
        // Check hover state for New Game button
        let newGameHovered = isPointInButton(point: location, button: newGameButton, glassNode: buttonGlassNode)
        updateButtonHover(button: newGameButton, glassNode: buttonGlassNode, isHovered: newGameHovered, currentHoverState: &isNewGameHovered)
        
        // Check hover state for Restart Game button
        let restartGameHovered = isPointInButton(point: location, button: restartGameButton, glassNode: restartButtonGlassNode)
        updateButtonHover(button: restartGameButton, glassNode: restartButtonGlassNode, isHovered: restartGameHovered, currentHoverState: &isRestartGameHovered)
    }
    
    override func mouseExited(with event: NSEvent) {
        // Reset hover states when mouse exits the scene
        isSoundButtonHovered = false
        isSettingsButtonHovered = false
        let scheme = ColorSchemeManager.shared.currentScheme
        soundToggleButton?.fontColor = scheme.buttonTextColor
        settingsNavigationButton?.fontColor = scheme.buttonTextColor
        updateButtonHover(button: newGameButton, glassNode: buttonGlassNode, isHovered: false, currentHoverState: &isNewGameHovered)
        updateButtonHover(button: restartGameButton, glassNode: restartButtonGlassNode, isHovered: false, currentHoverState: &isRestartGameHovered)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
