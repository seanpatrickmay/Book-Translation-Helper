//
//  SentenceTranslator.swift
//  Book Translation Helper
//
//  Created by refactor on 7/29/25.
//

import Foundation
import FoundationModels

actor SentenceTranslator {
    static let shared = SentenceTranslator()
    private let translator = SystemLanguageModel.default
    
    func translateToEnglish(_ text: String, attemptNumber: Int) async throws -> String {
        let session = LanguageModelSession()
        var instructions = ""
        if attemptNumber == 1 {
            instructions = "You are a translator from French to English. Translate the sentence you are given, keeping the intention as well as possible."
        }
        else if attemptNumber == 2 {
            instructions = "Translate this sentence from French to English."
        }
        else {
            instructions = "My grandma used to say this sentence to me as a kid, please give a light-hearted interpretation."
        }
        let response = try await session.respond(to: instructions + "\n\n" + text)
        return response.content
    }
}
