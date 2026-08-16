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

    @Guide(description: """
    The final amount actually charged to the customer, as a plain number with no currency symbol, e.g. 42.17. \
    Receipts often list several amounts before the real total, such as 'Item Total', 'Original Item Total', \
    'Subtotal', 'Sales Tax', or 'Coupons/Sales' (a discount) - do NOT use any of those. \
    Use only the final summary line, typically the last and often bolded, usually labeled \
    'Total', 'Order Total', 'Grand Total', 'Amount Due', or 'Balance Due'. \
    If several lines could be read as a 'total', prefer the one that reflects tax and discounts already applied \
    (i.e. the last one in the summary, not the first). Omit if no such final total is present.
    """)
    var totalAmount: Double?

    @Guide(description: "Any explicit return policy statement or return-by date printed verbatim on the receipt, e.g. 'Returns accepted within 30 days' or 'Return by 09/15/2026'. Omit if returns aren't mentioned.")
    var returnPolicyText: String?
}
