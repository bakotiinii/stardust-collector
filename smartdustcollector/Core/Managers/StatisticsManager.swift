//
//  StatisticsManager.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import Foundation

/// Manages game statistics persistence
final class StatisticsManager {
    static let shared = StatisticsManager()
    
    private let userDefaults: UserDefaults
    private let winsEasyKey = "winsEasy"
    private let winsMediumKey = "winsMedium"
    private let winsHardKey = "winsHard"
    private let totalGamesKey = "totalGames"
    
    /// Initialize with UserDefaults instance (allows dependency injection for testing)
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Statistics Properties
    
    /// Number of wins on easy difficulty
    var winsEasy: Int {
        get { userDefaults.integer(forKey: winsEasyKey) }
        set { userDefaults.set(newValue, forKey: winsEasyKey) }
    }
    
    /// Number of wins on medium difficulty
    var winsMedium: Int {
        get { userDefaults.integer(forKey: winsMediumKey) }
        set { userDefaults.set(newValue, forKey: winsMediumKey) }
    }
    
    /// Number of wins on hard difficulty
    var winsHard: Int {
        get { userDefaults.integer(forKey: winsHardKey) }
        set { userDefaults.set(newValue, forKey: winsHardKey) }
    }
    
    /// Total number of games played
    var totalGames: Int {
        get { userDefaults.integer(forKey: totalGamesKey) }
        set { userDefaults.set(newValue, forKey: totalGamesKey) }
    }
    
    // MARK: - Methods
    
    /// Record a game result
    /// - Parameters:
    ///   - won: Whether the game was won
    ///   - difficulty: The difficulty level of the game
    func recordGame(won: Bool, difficulty: Difficulty) {
        totalGames += 1
        
        guard won else { return }
        
        switch difficulty {
        case .easy:
            winsEasy += 1
        case .medium:
            winsMedium += 1
        case .hard:
            winsHard += 1
        }
    }
    
    /// Get wins for a specific difficulty
    /// - Parameter difficulty: The difficulty level
    /// - Returns: Number of wins for the given difficulty
    func wins(for difficulty: Difficulty) -> Int {
        switch difficulty {
        case .easy:
            return winsEasy
        case .medium:
            return winsMedium
        case .hard:
            return winsHard
        }
    }
    
    /// Reset all statistics to zero
    func resetStatistics() {
        winsEasy = 0
        winsMedium = 0
        winsHard = 0
        totalGames = 0
    }
}
