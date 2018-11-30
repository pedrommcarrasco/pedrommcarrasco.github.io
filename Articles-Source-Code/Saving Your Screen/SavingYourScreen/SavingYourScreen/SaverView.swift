//
//  SaverView.swift
//  SavingYourScreen
//
//  Created by Pedro Carrasco on 09/11/2018.
//  Copyright © 2018 Pedro Carrasco. All rights reserved.
//

import ScreenSaver

// MARK: - SaverView
final class SaverView: ScreenSaverView {
    
    // MARK: Outlets
    private let emojiLabel: Label = {
        let label = Label()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        configure()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        configure()
    }
}

// MARK: - Lifecycle
extension SaverView {
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        updateContent()
    }
}

// MARK: - Configuration
private extension SaverView {
    
    func configure() {
        animationTimeInterval = 1
        
        addSubviews()
        defineConstraints()
        setupSubviews()
    }
    
    func addSubviews() {
        addSubview(emojiLabel)
    }
    
    func defineConstraints() {
        NSLayoutConstraint.activate([emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }
    
    func setupSubviews() {
        emojiLabel.font = NSFont.systemFont(ofSize: bounds.height/5)
    }
}

// MARK: - Update
private extension SaverView {
    
    func updateContent() {
        guard let emoji = String.randomEmoji else { return }
        
        emojiLabel.stringValue = emoji
    }
}
