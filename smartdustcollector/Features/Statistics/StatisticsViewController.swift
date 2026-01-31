//
//  StatisticsViewController.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import Cocoa

protocol StatisticsViewControllerDelegate: AnyObject {
    func statisticsViewControllerDidRequestBack(_ controller: StatisticsViewController)
}

class StatisticsViewController: NSViewController, ColorSchemeApplicable {
    weak var delegate: StatisticsViewControllerDelegate?
    
    @IBOutlet var totalGamesLabel: NSTextField!
    @IBOutlet var winsEasyLabel: NSTextField!
    @IBOutlet var winsMediumLabel: NSTextField!
    @IBOutlet var winsHardLabel: NSTextField!
    
    override func loadView() {
        let optimalSize = calculateOptimalSize()
        view = NSView(frame: NSRect(x: 0, y: 0, width: optimalSize.width, height: optimalSize.height))
    }
    
    func calculateOptimalSize() -> CGSize {
        // Calculate optimal size based on content
        // Title: 30 top padding + 24 font size + 30 spacing = 84
        // Total games: 16 font size + 20 spacing = 36
        // Wins Easy: 16 font size + 15 spacing = 31
        // Wins Medium: 16 font size + 15 spacing = 31
        // Wins Hard: 16 font size + 20 spacing = 36
        // Back button: button height + 20 bottom padding = 56
        // Total approximate height: 84 + 36 + 31 + 31 + 36 + 56 = 274
        // But we use the actual frame size from loadView calculation
        let width: CGFloat = 300
        let height: CGFloat = 250
        return CGSize(width: width, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatistics()
        applyColorScheme()
        setupColorSchemeObserver()
    }
    
    deinit {
        removeColorSchemeObserver()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateStatistics()
        applyColorScheme()
    }
    
    func setupUI() {
        view.wantsLayer = true
        
        // Title label
        let titleLabel = NSTextField(labelWithString: "Statistics")
        titleLabel.font = NSFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Total games label
        let totalGamesLbl = NSTextField(labelWithString: "Total Games: 0")
        totalGamesLbl.font = NSFont.systemFont(ofSize: 16)
        totalGamesLbl.textColor = .labelColor
        totalGamesLbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalGamesLbl)
        totalGamesLabel = totalGamesLbl
        
        // Wins Easy label
        let winsEasyLbl = NSTextField(labelWithString: "Wins (Easy): 0")
        winsEasyLbl.font = NSFont.systemFont(ofSize: 16)
        winsEasyLbl.textColor = .labelColor
        winsEasyLbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(winsEasyLbl)
        winsEasyLabel = winsEasyLbl
        
        // Wins Medium label
        let winsMediumLbl = NSTextField(labelWithString: "Wins (Medium): 0")
        winsMediumLbl.font = NSFont.systemFont(ofSize: 16)
        winsMediumLbl.textColor = .labelColor
        winsMediumLbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(winsMediumLbl)
        winsMediumLabel = winsMediumLbl
        
        // Wins Hard label
        let winsHardLbl = NSTextField(labelWithString: "Wins (Hard): 0")
        winsHardLbl.font = NSFont.systemFont(ofSize: 16)
        winsHardLbl.textColor = .labelColor
        winsHardLbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(winsHardLbl)
        winsHardLabel = winsHardLbl
        
        // Back button
        let backBtn = NSButton(title: "← Back to Game", target: self, action: #selector(goBack))
        backBtn.bezelStyle = .rounded
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backBtn)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Total games
            totalGamesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            totalGamesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Wins Easy
            winsEasyLabel.topAnchor.constraint(equalTo: totalGamesLabel.bottomAnchor, constant: 20),
            winsEasyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Wins Medium
            winsMediumLabel.topAnchor.constraint(equalTo: winsEasyLabel.bottomAnchor, constant: 15),
            winsMediumLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Wins Hard
            winsHardLabel.topAnchor.constraint(equalTo: winsMediumLabel.bottomAnchor, constant: 15),
            winsHardLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Back button
            backBtn.topAnchor.constraint(equalTo: winsHardLabel.bottomAnchor, constant: 20),
            backBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func updateStatistics() {
        let stats = StatisticsManager.shared
        totalGamesLabel.stringValue = "Total Games: \(stats.totalGames)"
        winsEasyLabel.stringValue = "Wins (Easy): \(stats.winsEasy)"
        winsMediumLabel.stringValue = "Wins (Medium): \(stats.winsMedium)"
        winsHardLabel.stringValue = "Wins (Hard): \(stats.winsHard)"
    }
    
    @objc
    func goBack() {
        delegate?.statisticsViewControllerDidRequestBack(self)
    }
}
