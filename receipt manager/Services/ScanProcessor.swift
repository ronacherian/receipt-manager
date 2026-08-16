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
                // Vision doesn't guarantee reading order, so sort top-to-bottom, then left-to-right.
                let sorted = observations.sorted {
                    abs($0.boundingBox.midY - $1.boundingBox.midY) > 0.01
                        ? $0.boundingBox.midY > $1.boundingBox.midY
                        : $0.boundingBox.midX < $1.boundingBox.midX
                }
                let text = sorted.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
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
}
