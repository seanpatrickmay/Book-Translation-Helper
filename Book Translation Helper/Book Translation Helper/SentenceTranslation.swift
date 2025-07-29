//
//  SentenceTranslation.swift
//  Book Translation Helper
//
//  Created by refactor on 7/29/25.
//

import Foundation

struct SentenceTranslation: Identifiable {
    var id = UUID()
    var original: String
    var translation: String
}
