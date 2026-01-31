//
//  SettingsViewController.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import Cocoa

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsViewControllerDidSelectDifficulty(_ controller: SettingsViewController, difficulty: Difficulty)
    func settingsViewControllerDidRequestBack(_ controller: SettingsViewController)
    func settingsViewControllerDidRequestStatistics(_ controller: SettingsViewController)
}

class SettingsViewController: NSViewController, ColorSchemeApplicable {
    weak var delegate: SettingsViewControllerDelegate?
    var currentDifficulty: Difficulty = .easy
    
    @IBOutlet var easyButton: NSButton!
    @IBOutlet var mediumButton: NSButton!
    @IBOutlet var hardButton: NSButton!
    
    var colorSchemeButtons: [NSButton] = []
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 350, height: 360))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyColorScheme()
        setupColorSchemeObserver()
    }
    
    deinit {
        removeColorSchemeObserver()
    }
    
    func setupUI() {
        view.wantsLayer = true
        
        // Title label
        let titleLabel = NSTextField(labelWithString: "Settings")
        titleLabel.font = NSFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Color Scheme label
        let colorSchemeLabel = NSTextField(labelWithString: "Color Scheme:")
        colorSchemeLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        colorSchemeLabel.textColor = .labelColor
        colorSchemeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorSchemeLabel)
        
        // Color scheme buttons container
        let colorSchemeContainer = NSView()
        colorSchemeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorSchemeContainer)
        
        // Create color scheme buttons as colored square blocks
        setupColorSchemeButtons(in: colorSchemeContainer)
        
        // Difficulty label
        let difficultyLabel = NSTextField(labelWithString: "Difficulty:")
        difficultyLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        difficultyLabel.textColor = .labelColor
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(difficultyLabel)
        
        // Easy button
        let easyBtn = NSButton(title: "Easy", target: self, action: #selector(selectEasy))
        easyBtn.bezelStyle = .rounded
        easyBtn.wantsLayer = true
        easyBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(easyBtn)
        easyButton = easyBtn
        
        // Medium button
        let mediumBtn = NSButton(title: "Medium", target: self, action: #selector(selectMedium))
        mediumBtn.bezelStyle = .rounded
        mediumBtn.wantsLayer = true
        mediumBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mediumBtn)
        mediumButton = mediumBtn
        
        // Hard button
        let hardBtn = NSButton(title: "Hard", target: self, action: #selector(selectHard))
        hardBtn.bezelStyle = .rounded
        hardBtn.wantsLayer = true
        hardBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hardBtn)
        hardButton = hardBtn
        
        // Statistics button
        let statisticsBtn = NSButton(title: "Statistics", target: self, action: #selector(showStatistics))
        statisticsBtn.bezelStyle = .rounded
        statisticsBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statisticsBtn)
        
        // Back button
        let backBtn = NSButton(title: "← Back to Game", target: self, action: #selector(goBack))
        backBtn.bezelStyle = .rounded
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backBtn)
        
        // Layout constraints
        // Calculate color scheme container width
        let schemeCount = ColorScheme.allCases.count
        let buttonSize: CGFloat = 32
        let buttonSpacing: CGFloat = 8
        let totalButtonWidth = CGFloat(schemeCount) * buttonSize
        let totalSpacingWidth = CGFloat(schemeCount - 1) * buttonSpacing
        let containerWidth = totalButtonWidth + totalSpacingWidth
        
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Color Scheme label
            colorSchemeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            colorSchemeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Color scheme container
            colorSchemeContainer.topAnchor.constraint(equalTo: colorSchemeLabel.bottomAnchor, constant: 10),
            colorSchemeContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorSchemeContainer.widthAnchor.constraint(equalToConstant: containerWidth),
            colorSchemeContainer.heightAnchor.constraint(equalToConstant: 32),
            
            // Difficulty label
            difficultyLabel.topAnchor.constraint(equalTo: colorSchemeContainer.bottomAnchor, constant: 20),
            difficultyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Easy button
            easyButton.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 20),
            easyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            easyButton.widthAnchor.constraint(equalToConstant: 120),
            
            // Medium button
            mediumButton.topAnchor.constraint(equalTo: easyButton.bottomAnchor, constant: 10),
            mediumButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mediumButton.widthAnchor.constraint(equalToConstant: 120),
            
            // Hard button
            hardButton.topAnchor.constraint(equalTo: mediumButton.bottomAnchor, constant: 10),
            hardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hardButton.widthAnchor.constraint(equalToConstant: 120),
            
            // Statistics button
            statisticsBtn.topAnchor.constraint(equalTo: hardButton.bottomAnchor, constant: 20),
            statisticsBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsBtn.widthAnchor.constraint(equalToConstant: 120),
            
            // Back button
            backBtn.topAnchor.constraint(equalTo: statisticsBtn.bottomAnchor, constant: 20),
            backBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        updateButtonStates()
        updateColorSchemeButtons()
    }
    
    func updateButtonStates() {
        let scheme = ColorSchemeManager.shared.currentScheme
        
        // Set state
        easyButton.state = currentDifficulty == .easy ? .on : .off
        mediumButton.state = currentDifficulty == .medium ? .on : .off
        hardButton.state = currentDifficulty == .hard ? .on : .off
        
        // Configure button layers for visual distinction
        let buttons = [easyButton, mediumButton, hardButton]
        let difficulties: [Difficulty] = [.easy, .medium, .hard]
        
        for (index, button) in buttons.enumerated() {
            button?.wantsLayer = true
            if currentDifficulty == difficulties[index] {
                // Active button background using color scheme
                button?.layer?.backgroundColor = scheme.activeButtonBackgroundColor.cgColor
                button?.contentTintColor = NSColor.white
            } else {
                // Default/lighter appearance for inactive buttons
                button?.layer?.backgroundColor = NSColor.clear.cgColor
                button?.contentTintColor = nil
            }
        }
    }
    
    private func setupColorSchemeButtons(in container: NSView) {
        colorSchemeButtons.removeAll()
        let schemes = ColorScheme.allCases
        var previousButton: NSButton?
        let buttonSpacing: CGFloat = 8
        let buttonSize: CGFloat = 32  // Square size (reduced from 40)
        
        for (index, scheme) in schemes.enumerated() {
            // Create button without title - will show as colored block
            let btn = NSButton()
            btn.title = ""  // Explicitly remove any text
            btn.bezelStyle = .rounded
            btn.wantsLayer = true
            btn.tag = index
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.target = self
            btn.action = #selector(selectColorScheme(_:))
            
            // Set button to show colored background only (no text)
            btn.isBordered = false
            btn.layer?.cornerRadius = 5
            btn.layer?.borderWidth = 2
            
            // Add tooltip with scheme name
            btn.toolTip = scheme.displayName
            
            container.addSubview(btn)
            colorSchemeButtons.append(btn)
            
            if let prev = previousButton {
                NSLayoutConstraint.activate([
                    btn.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: buttonSpacing),
                    btn.topAnchor.constraint(equalTo: container.topAnchor),
                    btn.widthAnchor.constraint(equalToConstant: buttonSize),
                    btn.heightAnchor.constraint(equalToConstant: buttonSize)
                ])
            } else {
                NSLayoutConstraint.activate([
                    btn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    btn.topAnchor.constraint(equalTo: container.topAnchor),
                    btn.widthAnchor.constraint(equalToConstant: buttonSize),
                    btn.heightAnchor.constraint(equalToConstant: buttonSize)
                ])
            }
            previousButton = btn
        }
    }
    
    func updateColorSchemeButtons() {
        let currentScheme = ColorSchemeManager.shared.currentScheme
        let schemes = ColorScheme.allCases
        
        for (index, button) in colorSchemeButtons.enumerated() {
            guard index < schemes.count else { continue }
            let scheme = schemes[index]
            
            // Set the background color to the scheme's background color
            button.layer?.backgroundColor = scheme.backgroundColor.cgColor
            
            let isActive = scheme == currentScheme
            // Active color scheme button - add border highlight
            button.layer?.borderColor = isActive ? NSColor.controlAccentColor.cgColor : NSColor.gray.withAlphaComponent(0.3).cgColor
            button.layer?.borderWidth = isActive ? 3 : 2
        }
    }
    
    func applyColorScheme() {
        let scheme = ColorSchemeManager.shared.currentScheme
        view.layer?.backgroundColor = scheme.backgroundColor.cgColor
        updateButtonStates()
        updateColorSchemeButtons()
    }
    
    @objc
    func selectColorScheme(_ sender: NSButton) {
        let schemes = ColorScheme.allCases
        guard sender.tag < schemes.count else { return }
        
        let selectedScheme = schemes[sender.tag]
        ColorSchemeManager.shared.currentScheme = selectedScheme
        updateColorSchemeButtons()
    }
    
    @objc
    func selectEasy() {
        currentDifficulty = .easy
        updateButtonStates()
        delegate?.settingsViewControllerDidSelectDifficulty(self, difficulty: .easy)
    }
    
    @objc
    func selectMedium() {
        currentDifficulty = .medium
        updateButtonStates()
        delegate?.settingsViewControllerDidSelectDifficulty(self, difficulty: .medium)
    }
    
    @objc
    func selectHard() {
        currentDifficulty = .hard
        updateButtonStates()
        delegate?.settingsViewControllerDidSelectDifficulty(self, difficulty: .hard)
    }
    
    @objc
    func showStatistics() {
        delegate?.settingsViewControllerDidRequestStatistics(self)
    }
    
    @objc
    func goBack() {
        delegate?.settingsViewControllerDidRequestBack(self)
    }
}
