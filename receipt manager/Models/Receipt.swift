//
//  Receipt.swift
//  receipt manager
//

import Foundation
import SwiftData

@Model
final class Receipt {
    var storeName: String = ""
    var purchaseDate: Date = Date.now
    var totalAmount: Decimal = 0
    var currencyCode: String = "USD"
    var returnByDate: Date?
    var isReturnCompleted: Bool = false
    var rawOCRText: String = ""
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \ReceiptPage.receipt)
    var pages: [ReceiptPage]? = []

    init(storeName: String = "",
         purchaseDate: Date = .now,
         totalAmount: Decimal = 0,
         currencyCode: String = "USD",
         returnByDate: Date? = nil,
         isReturnCompleted: Bool = false,
         rawOCRText: String = "",
         createdAt: Date = .now) {
        self.storeName = storeName
        self.purchaseDate = purchaseDate
        self.totalAmount = totalAmount
        self.currencyCode = currencyCode
        self.returnByDate = returnByDate
        self.isReturnCompleted = isReturnCompleted
        self.rawOCRText = rawOCRText
        self.createdAt = createdAt
    }
}
