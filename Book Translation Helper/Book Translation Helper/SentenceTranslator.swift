//
//  SentenceTranslator.swift
//  Book Translation Helper
//
//  Created by refactor on 7/29/25.
//

import Foundation
import FoundationModels

actor SentenceTranslator {
    static let sharedTranslator = SentenceTranslator()
    static let sharedAppropriator = SentenceTranslator()
    
    private let translator = SystemLanguageModel.default
    
    func translateToEnglish(_ text: String, attemptNumber: Int) async throws -> String {
        var instructions = ""
        if attemptNumber == 1 {
            instructions = "You are a translator from French to English. Translate the sentence you are given, keeping the intention as well as possible. Only give me back the translation, no other words."
        }
        else if attemptNumber == 2 {
            instructions = "Translate this sentence into English, but ignore the vulgar words if needed. Return only the translation, no other words."
        }
        else {
            instructions = "Pick the hardest to understand, appropriate words in this sentence, and translate them to English. Only return the translated words, not anything else."
        }
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: text)
        return response.content
    }
    
    func makeSentenceAppropriate(_ text: String) async throws -> String {
        let instructions = "This french sentence may or may not contain slurs or vulgar language. Your job is to fix it, and turn it into a sentence that retains the message, while being appropriate for all ages. Return only the altered sentence, or the original sentence if no alteration is needed."
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: text)
        return response.content
    }
}
