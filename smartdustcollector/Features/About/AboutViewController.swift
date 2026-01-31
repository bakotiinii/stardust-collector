//
//  AboutViewController.swift
//  smartdustcollector
//
//  Created by Сергей Бакотин on 10.01.2026.
//

import Cocoa

protocol AboutViewControllerDelegate: AnyObject {
    func aboutViewControllerDidRequestBack(_ controller: AboutViewController)
}

class AboutViewController: NSViewController, ColorSchemeApplicable {
    weak var delegate: AboutViewControllerDelegate?
    
    override func loadView() {
        let optimalSize = calculateOptimalSize()
        view = NSView(frame: NSRect(x: 0, y: 0, width: optimalSize.width, height: optimalSize.height))
    }
    
    func calculateOptimalSize() -> CGSize {
        // Calculate optimal size based on content
        // Title: 30 top padding + 24 font size + 30 spacing = 84
        // Author: 16 font size + 20 spacing = 36
        // GitHub button: button height + 30 spacing = 66
        // Back button: button height + 20 bottom padding = 56
        // Total approximate height: 84 + 36 + 66 + 56 = 242
        // But we use the actual frame size from loadView calculation
        let width: CGFloat = 350
        let height: CGFloat = 250
        return CGSize(width: width, height: height)
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
    
    override func viewWillAppear() {
        super.viewWillAppear()
        applyColorScheme()
    }
    
    func setupUI() {
        view.wantsLayer = true
        
        // Title label
        let titleLabel = NSTextField(labelWithString: "About")
        titleLabel.font = NSFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Author name
        let authorLabel = NSTextField(labelWithString: "Sergey Bakotin")
        authorLabel.font = NSFont.systemFont(ofSize: 16, weight: .regular)
        authorLabel.textColor = .labelColor
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(authorLabel)
        
        // GitHub link button
        let githubBtn = NSButton(title: "GitHub", target: self, action: #selector(openGitHub))
        githubBtn.bezelStyle = .inline
        githubBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(githubBtn)
        
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
            
            // Author name
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            authorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // GitHub link
            githubBtn.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 20),
            githubBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Back button
            backBtn.topAnchor.constraint(equalTo: githubBtn.bottomAnchor, constant: 30),
            backBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc
    func goBack() {
        delegate?.aboutViewControllerDidRequestBack(self)
    }
    
    @objc
    func openGitHub() {
        if let url = URL(string: "https://github.com/bakotiinii") {
            NSWorkspace.shared.open(url)
        }
    }
}
