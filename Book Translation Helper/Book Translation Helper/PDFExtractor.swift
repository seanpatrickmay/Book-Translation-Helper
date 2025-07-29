//
//  PDFExtractor.swift
//  Book Translation Helper
//
//  Created by refactor on 7/29/25.
//

import PDFKit

struct PDFExtractor {
    static func extractText(from url: URL) -> String? {
        guard let doc = PDFDocument(url: url) else { return nil }
        var content = ""
        for i in 0..<(doc.pageCount) {
            if let page = doc.page(at: i) {
                if let text = page.string {
                    content += text + " "
                }
            }
        }
        return content
    }
    static func splitIntoSentences(text: String) -> [String] {
        // Use regex to split on sentence-ending punctuation
        let pattern = #"(?<=[.!?;])\s+"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            return regex.split(text)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        } else {
            return [text]
        }
    }
}

private extension NSRegularExpression {
    func split(_ string: String) -> [String] {
        var results = [String]()
        var lastIndex = string.startIndex
        let matches = self.matches(in: string, range: NSRange(string.startIndex..., in: string))
        for match in matches {
            let range = Range(match.range, in: string)!
            results.append(String(string[lastIndex..<range.lowerBound]))
            lastIndex = range.upperBound
        }
        results.append(String(string[lastIndex...]))
        return results
    }
}
