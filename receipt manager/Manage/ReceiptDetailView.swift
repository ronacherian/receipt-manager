//
//  ReceiptDetailView.swift
//  receipt manager
//
//

import SwiftUI
import SwiftData
import UIKit

private struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ReceiptDetailView: View {
    @Bindable var receipt: Receipt
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var zoomingImage: IdentifiableImage?

    private var sortedPages: [ReceiptPage] {
        (receipt.pages ?? []).sorted { $0.order < $1.order }
    }

    private var shareSummary: String {
        var lines: [String] = []
        let store = receipt.storeName.isEmpty ? "Unknown Merchant" : receipt.storeName
        lines.append("Store: \(store)")
        lines.append("Date: \(receipt.purchaseDate.formatted(date: .abbreviated, time: .omitted))")
        lines.append("Total: \(receipt.totalAmount.formatted(.currency(code: receipt.currencyCode)))")
        if let returnByDate = receipt.returnByDate {
            lines.append("Return by: \(returnByDate.formatted(date: .abbreviated, time: .omitted))")
            lines.append("Return status: \(receipt.isReturnCompleted ? "Returned" : "Pending")")
        }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        Form {
            if !sortedPages.isEmpty {
                Section {
                    TabView {
                        ForEach(sortedPages) { page in
                            if let uiImage = UIImage(data: page.imageData) {
                                Button {
                                    zoomingImage = IdentifiableImage(image: uiImage)
                                } label: {
                                    ZStack(alignment: .bottomTrailing) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                                        Label("Tap to zoom", systemImage: "arrow.up.left.and.arrow.down.right")
                                            .font(.caption2.bold())
                                            .padding(6)
                                            .background(.ultraThinMaterial, in: Capsule())
                                            .padding(8)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 320)
                    .listRowInsets(EdgeInsets())
                }
            }

            Section("Receipt") {
                TextField("Store name", text: $receipt.storeName)
                DatePicker("Purchase date", selection: $receipt.purchaseDate, displayedComponents: .date)
                HStack {
                    Text("Total")
                    Spacer()
                    Text(receipt.totalAmount, format: .currency(code: receipt.currencyCode))
                        .foregroundStyle(.secondary)
                }
            }

            Section("Return tracking") {
                Toggle("Track return deadline", isOn: Binding(
                    get: { receipt.returnByDate != nil },
                    set: { isOn in
                        receipt.returnByDate = isOn
                            ? ReturnDatePolicy.defaultReturnByDate(purchaseDate: receipt.purchaseDate)
                            : nil
                    }
                ))
                if let returnByDate = receipt.returnByDate {
                    DatePicker(
                        "Return by",
                        selection: Binding(
                            get: { returnByDate },
                            set: { receipt.returnByDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    Toggle("Marked as returned", isOn: $receipt.isReturnCompleted)
                }
            }

            Section {
                Button("Delete Receipt", role: .destructive) {
                    NotificationManager.shared.cancelReminders(for: receipt)
                    modelContext.delete(receipt)
                    dismiss()
                }
            }
        }
        .navigationTitle(receipt.storeName.isEmpty ? "Receipt" : receipt.storeName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let firstPageData = sortedPages.first?.imageData,
                   let uiImage = UIImage(data: firstPageData) {
                    ShareLink(
                        item: Image(uiImage: uiImage),
                        subject: Text(receipt.storeName.isEmpty ? "Receipt" : receipt.storeName),
                        message: Text(shareSummary),
                        preview: SharePreview(receipt.storeName.isEmpty ? "Receipt" : receipt.storeName, image: Image(uiImage: uiImage))
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } else {
                    ShareLink(item: shareSummary) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .fullScreenCover(item: $zoomingImage) { item in
            ZoomableImageView(image: item.image)
        }
        .onChange(of: receipt.returnByDate) {
            NotificationManager.shared.scheduleReturnReminders(for: receipt)
        }
        .onChange(of: receipt.isReturnCompleted) {
            if receipt.isReturnCompleted {
                NotificationManager.shared.cancelReminders(for: receipt)
            } else {
                NotificationManager.shared.scheduleReturnReminders(for: receipt)
            }
        }
    }
}
