//
//  Quote.swift
//  Paraphrase
//
//  Created by Paul Hudson on 05/05/2018.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import UIKit

struct Quote: Codable, Comparable {
    var author: String
    var text: String

    static func <(lhs: Quote, rhs: Quote) -> Bool {
        return lhs.author < rhs.author
    }
}
