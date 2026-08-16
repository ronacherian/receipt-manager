//
//  ScanView.swift
//  receipt manager
//

import SwiftUI
import UIKit

struct ScanView: View {
    @State private var showScanner = false
    @State private var showConfirmSheet = false
    @State private var isProcessing = false
    @State private var pendingPages: [ScannedPage] = []
    @State private var extraction: ReceiptExtraction?
    @State private var extractionNotice: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
                Text("Scan a receipt to save it and track its return deadline.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)

                Button {
                    showScanner = true
                } label: {
                    Label("Scan Receipt", systemImage: "camera.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 32)

                if isProcessing {
                    ProgressView("Reading receipt…")
                }
            }
            .navigationTitle("Scan")
            .fullScreenCover(isPresented: $showScanner) {
                DocumentCameraView { result in
                    showScanner = false
                    if case .success(let images) = result, !images.isEmpty {
                        Task { await process(images) }
                    }
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showConfirmSheet) {
                ReceiptConfirmSheet(scannedPages: pendingPages, extraction: extraction, notice: extractionNotice)
            }
        }
    }

    private func process(_ images: [UIImage]) async {
        isProcessing = true
        defer { isProcessing = false }

        guard let pages = try? await ScanProcessor.process(pages: images) else { return }
        pendingPages = pages

        let combinedText = pages.map(\.recognizedText).joined(separator: "\n\n")

        switch ExtractionAvailability.current() {
        case .available:
            do {
                extraction = try await ReceiptExtractor().extract(from: combinedText)
                extractionNotice = nil
            } catch {
                extraction = nil
                extractionNotice = "Couldn't read this receipt automatically (\(error.localizedDescription)). Please fill in the details below."
            }
        case .unavailable(let reason):
            extraction = nil
            extractionNotice = "On-device Apple Intelligence isn't available right now (\(reason)). Please fill in the details below."
        }

        showConfirmSheet = true
    }
}
