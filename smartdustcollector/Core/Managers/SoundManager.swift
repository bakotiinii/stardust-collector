//
//  SoundManager.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 27.01.2026.
//

import AppKit
import SpriteKit

/// Errors that can occur when playing sounds
enum SoundError: Error {
    case fileNotFound(String)
    case failedToCreateSound(String)
    case soundDisabled
}

/// Manages sound playback for the game
final class SoundManager {
    static let shared = SoundManager()
    
    /// Sound file names (WAV format) - located in Resources/Sounds folder
    private enum SoundFile: String {
        case plantBomb = "plant_bomb.wav"
        case blowBomb = "blow_bomb.wav"
        case findStar = "find_star.wav"
        case won = "won.wav"
        case lose = "lose.wav"
    }
    
    /// Cache for NSSound instances
    private var sounds: [String: NSSound] = [:]
    
    /// Sound enabled/disabled state (default: enabled)
    private(set) var isSoundEnabled: Bool = true
    
    private init() {}
    
    /// Play sound using NSSound (supports WAV, AIFF, NeXT SND formats on macOS)
    /// - Parameters:
    ///   - soundName: Name of the sound file
    ///   - node: SKNode to associate with (for context)
    /// - Returns: Result indicating success or failure
    @discardableResult
    func playSound(_ soundName: String, onNode node: SKNode) -> Result<Void, SoundError> {
        guard isSoundEnabled else {
            return .failure(.soundDisabled)
        }
        
        // Extract filename and extension
        let fileNameWithoutExtension = (soundName as NSString).deletingPathExtension
        let fileExtension = (soundName as NSString).pathExtension
        
        // Find the file in bundle (searches recursively including Resources/Sounds folder)
        guard let path = Bundle.main.path(forResource: fileNameWithoutExtension, ofType: fileExtension) else {
            let error = SoundError.fileNotFound("\(fileNameWithoutExtension).\(fileExtension)")
            print("SoundManager: \(error)")
            return .failure(error)
        }
        
        // Use cached sound or create new one
        if let sound = sounds[soundName] {
            // If sound is not playing, play it
            if !sound.isPlaying {
                sound.stop()
                sound.play()
            }
        } else {
            // Create new NSSound
            guard let sound = NSSound(contentsOfFile: path, byReference: false) else {
                let error = SoundError.failedToCreateSound(path)
                print("SoundManager: \(error)")
                return .failure(error)
            }
            sounds[soundName] = sound
            sound.play()
            print("SoundManager: Playing sound: \(soundName) from path: \(path)")
        }
        
        return .success(())
    }
    
    /// Toggle sound on/off
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    // MARK: - Convenience Methods
    
    /// Play plant bomb sound
    func playPlantBombSound(onNode node: SKNode) {
        _ = playSound(SoundFile.plantBomb.rawValue, onNode: node)
    }
    
    /// Play blow bomb sound
    func playBlowBombSound(onNode node: SKNode) {
        _ = playSound(SoundFile.blowBomb.rawValue, onNode: node)
    }
    
    /// Play find star sound
    func playFindStarSound(onNode node: SKNode) {
        _ = playSound(SoundFile.findStar.rawValue, onNode: node)
    }
    
    /// Play won sound
    func playWonSound(onNode node: SKNode) {
        _ = playSound(SoundFile.won.rawValue, onNode: node)
    }
    
    /// Play lose sound
    func playLoseSound(onNode node: SKNode) {
        _ = playSound(SoundFile.lose.rawValue, onNode: node)
    }
}
