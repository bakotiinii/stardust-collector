//
//  CellState.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import Foundation

/// Represents the state of a single game cell
struct CellState {
    var hasStar: Bool = false
    var hasRock: Bool = false
    var hasStarDust: Bool = false
    var isDestroyed: Bool = false
    var hasBomb: Bool = false
    
    mutating func reset() {
        hasStar = false
        hasRock = false
        hasStarDust = false
        isDestroyed = false
        hasBomb = false
    }
}
