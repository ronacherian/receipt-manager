//
//  ReceiptExtraction.swift
//  receipt manager
//

import FoundationModels

@Generable
struct ReceiptExtraction {
    @Guide(description: "The store or merchant name printed on the receipt, e.g. 'Target'. Omit if not legible.")
    var storeName: String?

    @Guide(description: "The purchase date exactly as printed on the receipt, e.g. '08/14/2026'. Omit if not present.")
    var purchaseDateText: String?

    @Guide(description: "The final total amount charged, as a plain number with no currency symbol, e.g. 42.17. Omit if not present.")
    var totalAmount: Double?

    @Guide(description: "Any explicit return policy statement or return-by date printed verbatim on the receipt, e.g. 'Returns accepted within 30 days' or 'Return by 09/15/2026'. Omit if returns aren't mentioned.")
    var returnPolicyText: String?
}
