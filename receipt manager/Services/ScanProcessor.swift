//
//  ScanProcessor.swift
//  receipt manager
//

import UIKit
import Vision

struct ScannedPage {
    let imageData: Data
    let recognizedText: String
}

enum ScanProcessor {
    static func process(pages: [UIImage]) async throws -> [ScannedPage] {
        try await withThrowingTaskGroup(of: (Int, ScannedPage).self) { group in
            for (index, image) in pages.enumerated() {
                group.addTask {
                    let text = try await recognizeText(in: image)
                    let data = image.jpegData(compressionQuality: 0.7) ?? Data()
                    return (index, ScannedPage(imageData: data, recognizedText: text))
                }
            }
            var results = [Int: ScannedPage]()
            for try await (index, page) in group {
                results[index] = page
            }
            return (0..<pages.count).compactMap { results[$0] }
        }
    }

    private static func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { return "" }
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
                let text = Self.reconstructReadingOrder(from: observations)
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            do {
                try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Vision returns observations in no guaranteed order. Reconstruct reading order by clustering
    /// observations into horizontal lines (by vertical center, within a fraction of line height) and
    /// then ordering each line's words left-to-right — a single left-to-right/top-to-bottom `sorted`
    /// comparator isn't a valid strict ordering here since "same line" isn't a transitive relation,
    /// which was scrambling multi-column receipt layouts (e.g. a label separated from its amount).
    static func reconstructReadingOrder(from observations: [VNRecognizedTextObservation]) -> String {
        // Vision's normalized image coordinates have their origin at the bottom-left with y increasing
        // upward, so descending midY walks the page top-to-bottom.
        let topToBottom = observations.sorted { $0.boundingBox.midY > $1.boundingBox.midY }

        var lines: [[VNRecognizedTextObservation]] = []
        for observation in topToBottom {
            let lineHeight = observation.boundingBox.height
            if let lastLine = lines.last,
               let reference = lastLine.first,
               abs(observation.boundingBox.midY - reference.boundingBox.midY) < lineHeight * 0.6 {
                lines[lines.count - 1].append(observation)
            } else {
                lines.append([observation])
            }
        }

        return lines
            .map { line in
                line.sorted { $0.boundingBox.midX < $1.boundingBox.midX }
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: " ")
            }
            .joined(separator: "\n")
    }
}
