//
//  ContentView.swift
//  Book Translation Helper
//
//  Created by Sean May on 7/29/25.
//

import SwiftUI
import PDFKit
internal import UniformTypeIdentifiers
import FoundationModels

struct ContentView: View {
    @State private var sentences: [SentenceTranslation] = []
    @State private var showingDocumentPicker = false
    @State private var hoverSentenceID: UUID? = nil
    
    @State private var isTranslating = false
    @State private var translationProgress: Double = 0

    var body: some View {
        VStack {
            Button("Import PDF") {
                showingDocumentPicker = true
            }
            .padding()
            
            if isTranslating {
                ProgressView("Translating…", value: translationProgress, total: 1.0)
                    .padding()
            }
            
            if !sentences.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach($sentences) { $sentence in
                            HStack(alignment: .center, spacing: 6) {
                                Text($sentence.original.wrappedValue)
                                    .onHover { hovering in
                                        hoverSentenceID = hovering ? $sentence.id.wrappedValue : nil
                                    }
                                if hoverSentenceID == $sentence.id.wrappedValue {
                                    if !$sentence.translation.wrappedValue.isEmpty {
                                        Text($sentence.translation.wrappedValue)
                                            .font(.caption)
                                            .padding(4)
                                            .background(Color.secondary)
                                            .cornerRadius(4)
                                            .transition(.opacity)
                                    } else {
                                        ProgressView()
                                            .frame(width: 60, height: 16)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Text("No PDF imported yet.")
                    .foregroundStyle(.secondary)
            }
        }
        .fileImporter(isPresented: $showingDocumentPicker, allowedContentTypes: [.pdf]) { result in
            switch result {
            case .success(let url):
                print("PDF import result: \(url)")
                let didAccess = url.startAccessingSecurityScopedResource()
                defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
                isTranslating = true
                translationProgress = 0
                if let text = PDFExtractor.extractText(from: url) {
                    print("Extracted text (first 200 chars): \(text.prefix(200))")
                    let splitSentences = PDFExtractor.splitIntoSentences(text: text)
                    print("Split sentences (by period): \(splitSentences.count) sentences")
                    sentences = splitSentences.map { SentenceTranslation(original: $0, translation: "") }
                    Task {
                        print("Beginning translation of sentences")
                        let translator = SentenceTranslator.sharedTranslator
                        let appropriator = SentenceTranslator.sharedAppropriator
                        for idx in sentences.indices {
                            var attempts = 0
                            let maxAttempts = 3
                            var success = false
                            let madeAppropriate = try await appropriator.makeSentenceAppropriate(sentences[idx].original)
                            print("Made appropriate string: \(madeAppropriate) from: \(sentences[idx].original)")
                            while attempts < maxAttempts && !success {
                                do {
                                    let translated = try await translator.translateToEnglish(madeAppropriate, attemptNumber: attempts + 1)
                                    sentences[idx].translation = translated
                                    success = true
                                } catch {
                                    attempts += 1
                                    if attempts == maxAttempts {
                                        print("Translation failed for sentence [\(sentences[idx].original)] after \(maxAttempts) attempts:", error)
                                        sentences[idx].translation = "[Translation failed]"
                                    }
                                }
                            }
                            translationProgress = Double(idx + 1) / Double(sentences.count)
                        }
                        isTranslating = false
                    }
                } else {
                    print("PDF text extraction failed for URL: \(url)")
                    isTranslating = false
                }
            case .failure:
                print("PDF import failed: \(result)")
                isTranslating = false
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
