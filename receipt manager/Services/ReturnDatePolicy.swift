//
//  ReturnDatePolicy.swift
//  receipt manager
//

import Foundation

enum ReturnDatePolicy {
    static let defaultReturnWindowDays = 30

    static func defaultReturnByDate(purchaseDate: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: defaultReturnWindowDays, to: purchaseDate) ?? purchaseDate
    }

    /// Converts a date *string* already identified by OCR/the model into a concrete Date.
    static func parseDate(from text: String?) -> Date? {
        guard let text, !text.isEmpty,
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        return detector.firstMatch(in: text, range: range)?.date
    }
}
