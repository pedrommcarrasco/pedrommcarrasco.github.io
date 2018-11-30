//
//  String+Emoji.swift
//  SavingYourScreen
//
//  Created by Pedro Carrasco on 09/11/2018.
//  Copyright © 2018 Pedro Carrasco. All rights reserved.
//

import Foundation

extension String {
    
    static var randomEmoji: String? {
        guard let randomEmojiAscii = [UInt32](0x1F601...0x1F64F).randomElement() else { return nil }

        return UnicodeScalar(randomEmojiAscii)?.description
    }
}
