//
//  ReceiptConfirmSheet.swift
//  receipt manager
//

import SwiftUI
import SwiftData
import Foundation

struct ReceiptConfirmSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let scannedPages: [ScannedPage]
    let extraction: ReceiptExtraction?
    var notice: String?

    @State private var storeName: String = ""
    @State private var purchaseDate: Date = .now
    @State private var totalAmountText: String = ""
    @State private var trackReturn: Bool = true
    @State private var returnByDate: Date = ReturnDatePolicy.defaultReturnByDate(purchaseDate: .now)

    var body: some View {
        NavigationStack {
            Form {
                if let notice {
                    Section {
                        Text(notice)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Receipt") {
                    TextField("Store name", text: $storeName)
                    DatePicker("Purchase date", selection: $purchaseDate, displayedComponents: .date)
                    TextField("Total amount", text: $totalAmountText)
                        .keyboardType(.decimalPad)
                }
                Section("Return tracking") {
                    Toggle("Track return deadline", isOn: $trackReturn)
                    if trackReturn {
                        DatePicker("Return by", selection: $returnByDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Confirm Receipt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(storeName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { prefill() }
        }
    }

    private func prefill() {
        let parsedPurchaseDate = ReturnDatePolicy.parseDate(from: extraction?.purchaseDateText) ?? .now
        purchaseDate = parsedPurchaseDate

        storeName = extraction?.storeName ?? ""
        if let totalAmount = extraction?.totalAmount {
            totalAmountText = String(format: "%.2f", totalAmount)
        }

        if let explicitReturnDate = ReturnDatePolicy.parseDate(from: extraction?.returnPolicyText) {
            returnByDate = explicitReturnDate
        } else {
            returnByDate = ReturnDatePolicy.defaultReturnByDate(purchaseDate: parsedPurchaseDate)
        }
    }

    private func save() {
        let total = Decimal(string: totalAmountText) ?? 0
        let receipt = Receipt(
            storeName: storeName.trimmingCharacters(in: .whitespaces),
            purchaseDate: purchaseDate,
            totalAmount: total,
            returnByDate: trackReturn ? returnByDate : nil,
            rawOCRText: scannedPages.map(\.recognizedText).joined(separator: "\n\n")
        )
        modelContext.insert(receipt)

        for (index, page) in scannedPages.enumerated() {
            let receiptPage = ReceiptPage(order: index, imageData: page.imageData, receipt: receipt)
            modelContext.insert(receiptPage)
        }

        dismiss()
    }
}
