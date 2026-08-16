//
//  ReceiptListLogic.swift
//  receipt manager
//

import Foundation

enum ReturnFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case due = "Returns Due"
    case completed = "Returned"

    var id: String { rawValue }
}

enum SortOption: String, CaseIterable, Identifiable {
    case dateDescending = "Newest"
    case dateAscending = "Oldest"
    case store = "Store"
    case amount = "Amount"

    var id: String { rawValue }
}

/// Pure filter/sort/group logic, kept out of the view so it's testable without SwiftData or SwiftUI.
enum ReceiptListLogic {
    static func filteredAndSorted(_ receipts: [Receipt], filter: ReturnFilter, sort sortOption: SortOption) -> [Receipt] {
        var result = filtered(receipts, filter: filter)
        sort(&result, by: sortOption)
        return result
    }

    static func filtered(_ receipts: [Receipt], filter: ReturnFilter) -> [Receipt] {
        switch filter {
        case .all:
            return receipts
        case .due:
            return receipts.filter { $0.returnByDate != nil && !$0.isReturnCompleted }
        case .completed:
            return receipts.filter(\.isReturnCompleted)
        }
    }

    static func sort(_ receipts: inout [Receipt], by option: SortOption) {
        switch option {
        case .dateDescending:
            receipts.sort { $0.purchaseDate > $1.purchaseDate }
        case .dateAscending:
            receipts.sort { $0.purchaseDate < $1.purchaseDate }
        case .store:
            receipts.sort { $0.storeName.localizedCaseInsensitiveCompare($1.storeName) == .orderedAscending }
        case .amount:
            receipts.sort { $0.totalAmount > $1.totalAmount }
        }
    }

    static func groupedByStore(_ receipts: [Receipt]) -> [(store: String, receipts: [Receipt])] {
        Dictionary(grouping: receipts, by: \.storeName)
            .map { (store: $0.key, receipts: $0.value) }
            .sorted { $0.store.localizedCaseInsensitiveCompare($1.store) == .orderedAscending }
    }
}
