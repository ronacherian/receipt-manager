//
//  ReceiptFilteringTests.swift
//  receipt managerTests
//
//

import Testing
import Foundation
@testable import receipt_manager

struct ReceiptFilteringTests {

    private func makeReceipt(store: String,
                              daysAgo: Int,
                              total: Decimal,
                              returnByDaysFromNow: Int? = nil,
                              isReturnCompleted: Bool = false,
                              rawOCRText: String = "") -> Receipt {
        let purchaseDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!
        let returnByDate = returnByDaysFromNow.map {
            Calendar.current.date(byAdding: .day, value: $0, to: .now)!
        }
        return Receipt(
            storeName: store,
            purchaseDate: purchaseDate,
            totalAmount: total,
            returnByDate: returnByDate,
            isReturnCompleted: isReturnCompleted,
            rawOCRText: rawOCRText
        )
    }

    @Test func dueFilterIncludesExpiredReturns() {
        let expired = makeReceipt(store: "Target", daysAgo: 60, total: 10, returnByDaysFromNow: -5)
        let upcoming = makeReceipt(store: "Costco", daysAgo: 5, total: 20, returnByDaysFromNow: 10)
        let untracked = makeReceipt(store: "Corner Store", daysAgo: 1, total: 5)

        let due = ReceiptListLogic.filtered([expired, upcoming, untracked], filter: .due)

        #expect(due.count == 2)
        #expect(due.contains { $0.storeName == "Target" })
        #expect(due.contains { $0.storeName == "Costco" })
    }

    @Test func completedFilterOnlyIncludesReturnedReceipts() {
        let returned = makeReceipt(store: "Target", daysAgo: 10, total: 10, returnByDaysFromNow: -1, isReturnCompleted: true)
        let notReturned = makeReceipt(store: "Costco", daysAgo: 5, total: 20, returnByDaysFromNow: 10)

        let completed = ReceiptListLogic.filtered([returned, notReturned], filter: .completed)

        #expect(completed.count == 1)
        #expect(completed.first?.storeName == "Target")
    }

    @Test func allFilterReturnsEverything() {
        let a = makeReceipt(store: "A", daysAgo: 1, total: 1)
        let b = makeReceipt(store: "B", daysAgo: 2, total: 2)

        #expect(ReceiptListLogic.filtered([a, b], filter: .all).count == 2)
    }

    @Test func sortByDateDescendingOrdersNewestFirst() {
        let older = makeReceipt(store: "A", daysAgo: 10, total: 1)
        let newer = makeReceipt(store: "B", daysAgo: 1, total: 1)
        var receipts = [older, newer]

        ReceiptListLogic.sort(&receipts, by: .dateDescending)

        #expect(receipts.first?.storeName == "B")
    }

    @Test func sortByAmountOrdersHighestFirst() {
        let small = makeReceipt(store: "A", daysAgo: 1, total: 5)
        let large = makeReceipt(store: "B", daysAgo: 1, total: 50)
        var receipts = [small, large]

        ReceiptListLogic.sort(&receipts, by: .amount)

        #expect(receipts.first?.storeName == "B")
    }

    @Test func sortByStoreOrdersAlphabetically() {
        let z = makeReceipt(store: "Zeller's", daysAgo: 1, total: 5)
        let a = makeReceipt(store: "Ace Hardware", daysAgo: 1, total: 5)
        var receipts = [z, a]

        ReceiptListLogic.sort(&receipts, by: .store)

        #expect(receipts.first?.storeName == "Ace Hardware")
    }

    @Test func groupedByStoreGroupsAndSortsAlphabetically() {
        let target1 = makeReceipt(store: "Target", daysAgo: 1, total: 5)
        let target2 = makeReceipt(store: "Target", daysAgo: 2, total: 10)
        let costco = makeReceipt(store: "Costco", daysAgo: 1, total: 20)

        let groups = ReceiptListLogic.groupedByStore([target1, target2, costco])

        #expect(groups.map(\.store) == ["Costco", "Target"])
        #expect(groups.first { $0.store == "Target" }?.receipts.count == 2)
    }

    @Test func searchMatchesStoreName() {
        let target = makeReceipt(store: "Target", daysAgo: 1, total: 20)
        let bestBuy = makeReceipt(store: "Best Buy", daysAgo: 2, total: 50)
        let apple = makeReceipt(store: "Apple Store", daysAgo: 3, total: 100)

        let results = ReceiptListLogic.searched([target, bestBuy, apple], query: "target")
        #expect(results.count == 1)
        #expect(results.first?.storeName == "Target")
    }

    @Test func searchMatchesOCRText() {
        let r1 = makeReceipt(store: "Supermarket", daysAgo: 1, total: 20, rawOCRText: "Organic Bananas Milk Bread")
        let r2 = makeReceipt(store: "Tech Hub", daysAgo: 2, total: 50, rawOCRText: "USB-C Cable Charger")

        let results = ReceiptListLogic.searched([r1, r2], query: "bananas")
        #expect(results.count == 1)
        #expect(results.first?.storeName == "Supermarket")
    }

    @Test func filteredAndSortedWithSearchSortsByStoreName() {
        let zStore = makeReceipt(store: "Zara", daysAgo: 1, total: 50, rawOCRText: "Black Leather Jacket")
        let aStore = makeReceipt(store: "Amazon", daysAgo: 10, total: 25, rawOCRText: "Winter Jacket")
        let hStore = makeReceipt(store: "H&M", daysAgo: 5, total: 30, rawOCRText: "Puffer Jacket")

        let results = ReceiptListLogic.filteredAndSorted(
            [zStore, aStore, hStore],
            filter: .all,
            sort: .dateDescending,
            searchQuery: "jacket"
        )

        #expect(results.count == 3)
        #expect(results.map(\.storeName) == ["Amazon", "H&M", "Zara"])
    }
}
