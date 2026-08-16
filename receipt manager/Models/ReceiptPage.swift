//
//  ReceiptPage.swift
//  receipt manager
//

import Foundation
import SwiftData

@Model
final class ReceiptPage {
    var order: Int = 0
    @Attribute(.externalStorage) var imageData: Data = Data()
    var receipt: Receipt?

    init(order: Int = 0, imageData: Data = Data(), receipt: Receipt? = nil) {
        self.order = order
        self.imageData = imageData
        self.receipt = receipt
    }
}
