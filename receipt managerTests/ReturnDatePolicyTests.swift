//
//  ReturnDatePolicyTests.swift
//  receipt managerTests
//

import Testing
import Foundation
@testable import receipt_manager

struct ReturnDatePolicyTests {

    @Test func defaultReturnByDateAddsThirtyDays() {
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = 16
        let purchaseDate = Calendar.current.date(from: components)!

        let returnByDate = ReturnDatePolicy.defaultReturnByDate(purchaseDate: purchaseDate)
        let expectedComponents = Calendar.current.dateComponents([.year, .month, .day], from: returnByDate)

        #expect(expectedComponents.year == 2026)
        #expect(expectedComponents.month == 9)
        #expect(expectedComponents.day == 15)
    }

    @Test func defaultReturnByDateCrossesYearBoundary() {
        var components = DateComponents()
        components.year = 2026
        components.month = 12
        components.day = 20
        let purchaseDate = Calendar.current.date(from: components)!

        let returnByDate = ReturnDatePolicy.defaultReturnByDate(purchaseDate: purchaseDate)
        let expectedComponents = Calendar.current.dateComponents([.year, .month, .day], from: returnByDate)

        #expect(expectedComponents.year == 2027)
        #expect(expectedComponents.month == 1)
        #expect(expectedComponents.day == 19)
    }

    @Test func defaultReturnByDateCrossesLeapYearBoundary() {
        var components = DateComponents()
        components.year = 2028
        components.month = 1
        components.day = 31
        let purchaseDate = Calendar.current.date(from: components)!

        let returnByDate = ReturnDatePolicy.defaultReturnByDate(purchaseDate: purchaseDate)
        let expectedComponents = Calendar.current.dateComponents([.year, .month, .day], from: returnByDate)

        // 2028 is a leap year, so February has 29 days.
        #expect(expectedComponents.year == 2028)
        #expect(expectedComponents.month == 3)
        #expect(expectedComponents.day == 1)
    }

    @Test func parseDateExtractsDateFromText() {
        let parsed = ReturnDatePolicy.parseDate(from: "Return by 09/15/2026")
        let components = parsed.map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }

        #expect(components?.year == 2026)
        #expect(components?.month == 9)
        #expect(components?.day == 15)
    }

    @Test func parseDateReturnsNilForNonDateText() {
        #expect(ReturnDatePolicy.parseDate(from: "Thank you for shopping with us") == nil)
    }

    @Test func parseDateReturnsNilForNilInput() {
        #expect(ReturnDatePolicy.parseDate(from: nil) == nil)
    }
}
