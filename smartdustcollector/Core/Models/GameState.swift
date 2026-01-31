//
//  GameState.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import Foundation

/// Represents the current state of the game
struct GameState {
    var bombsPlaced: Int = 0
    var starsCollected: Int = 0
    var pendingBombs: Int = 0
    var isGameOver: Bool = false
    var isGameWon: Bool = false
    var statisticsRecorded: Bool = false
    
    mutating func reset() {
        bombsPlaced = 0
        starsCollected = 0
        pendingBombs = 0
        isGameOver = false
        isGameWon = false
        statisticsRecorded = false
    }
}
