//
//  Difficulty.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import Foundation

/// Represents game difficulty levels
enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard
    
    var gridSize: Int {
        switch self {
        case .easy: return 9
        case .medium: return 12
        case .hard: return 15
        }
    }
    
    var totalStars: Int {
        switch self {
        case .easy: return 6
        case .medium: return 10
        case .hard: return 12
        }
    }
    
    var totalRocks: Int {
        switch self {
        case .easy: return 10
        case .medium: return 18
        case .hard: return 28
        }
    }
    
    var maxBombs: Int {
        switch self {
        case .easy: return 9
        case .medium: return 15
        case .hard: return 22
        }
    }
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}
