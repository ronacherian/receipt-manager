//
//  ReceiptExtractor.swift
//  receipt manager
//

import FoundationModels

enum ExtractionAvailability: Equatable {
    case available
    case unavailable(reason: String)

    static func current() -> ExtractionAvailability {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .available
        case .unavailable(let reason):
            return .unavailable(reason: String(describing: reason))
        }
    }
}

struct ReceiptExtractor {
    func extract(from ocrText: String) async throws -> ReceiptExtraction {
        let session = LanguageModelSession(
            instructions: """
            You extract structured purchase details from OCR text scanned from a paper retail receipt. \
            Only use information explicitly present in the text; never guess or invent values.
            """
        )
        let response = try await session.respond(
            to: "Receipt OCR text:\n\(ocrText)",
            generating: ReceiptExtraction.self
        )
        return response.content
    }
}
