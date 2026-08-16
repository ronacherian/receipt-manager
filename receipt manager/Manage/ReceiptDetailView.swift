//
//  ReceiptDetailView.swift
//  receipt manager
//

import SwiftUI
import SwiftData
import UIKit

struct ReceiptDetailView: View {
    @Bindable var receipt: Receipt
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var sortedPages: [ReceiptPage] {
        (receipt.pages ?? []).sorted { $0.order < $1.order }
    }

    var body: some View {
        Form {
            if !sortedPages.isEmpty {
                Section {
                    TabView {
                        ForEach(sortedPages) { page in
                            if let uiImage = UIImage(data: page.imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
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
                    modelContext.delete(receipt)
                    dismiss()
                }
            }
        }
        .navigationTitle(receipt.storeName.isEmpty ? "Receipt" : receipt.storeName)
    }
}
