//
//  ReceiptRowView.swift
//  receipt manager
//

import SwiftUI

struct ReceiptRowView: View {
    let receipt: Receipt

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(receipt.storeName)
                    .font(.headline)
                Text(receipt.purchaseDate, format: .dateTime.month().day().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(receipt.totalAmount, format: .currency(code: receipt.currencyCode))
                    .font(.subheadline)
                returnBadge
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var returnBadge: some View {
        if receipt.isReturnCompleted {
            Label("Returned", systemImage: "checkmark.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.green)
        } else if let returnByDate = receipt.returnByDate {
            let isPastDue = returnByDate < .now
            Text(returnByDate, format: .dateTime.month().day())
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isPastDue ? .red.opacity(0.15) : .orange.opacity(0.15))
                .foregroundStyle(isPastDue ? .red : .orange)
                .clipShape(Capsule())
        }
    }
}
