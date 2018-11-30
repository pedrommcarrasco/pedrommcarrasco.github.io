//
//  Label.swift
//  SavingYourScreen
//
//  Created by Pedro Carrasco on 09/11/2018.
//  Copyright © 2018 Pedro Carrasco. All rights reserved.
//

import AppKit

// MARK: - Label
final class Label: NSTextField {
    
    // MARK: Initialization
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
}

// MARK: - Configuration
private extension Label {
    
    func configure() {
        
        isBezeled = false
        isSelectable = false
        drawsBackground = false
    }
}
