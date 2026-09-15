//
//  ManageView.swift
//  receipt manager
//

import SwiftUI
import SwiftData

struct ManageView: View {
    @Query(sort: \Receipt.purchaseDate, order: .reverse) private var receipts: [Receipt]
    @Environment(\.modelContext) private var modelContext

    @State private var filter: ReturnFilter = .all
    @State private var sortOption: SortOption = .dateDescending
    @State private var groupByStore = false
    @State private var searchText = ""

    private var visibleReceipts: [Receipt] {
        ReceiptListLogic.filteredAndSorted(receipts, filter: filter, sort: sortOption, searchQuery: searchText)
    }

    private var groups: [(store: String, receipts: [Receipt])] {
        ReceiptListLogic.groupedByStore(visibleReceipts)
    }

    var body: some View {
        NavigationStack {
            List {
                if visibleReceipts.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Receipts" : "No Results",
                        systemImage: searchText.isEmpty ? "tray" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Scan a receipt to see it here." : "No receipts matching \"\(searchText)\".")
                    )
                } else if groupByStore {
                    ForEach(groups, id: \.store) { group in
                        Section(group.store) {
                            ForEach(group.receipts) { receipt in
                                receiptRow(receipt)
                            }
                        }
                    }
                } else {
                    ForEach(visibleReceipts) { receipt in
                        receiptRow(receipt)
                    }
                }
            }
            .navigationTitle("Manage")
            .searchable(text: $searchText, prompt: "Search stores or receipt items")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Toggle("Group by Store", isOn: $groupByStore)
                        .toggleStyle(.button)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                Picker("Filter", selection: $filter) {
                    ForEach(ReturnFilter.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }

    private func receiptRow(_ receipt: Receipt) -> some View {
        NavigationLink {
            ReceiptDetailView(receipt: receipt)
        } label: {
            ReceiptRowView(receipt: receipt)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                NotificationManager.shared.cancelReminders(for: receipt)
                modelContext.delete(receipt)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            if !receipt.isReturnCompleted {
                Button {
                    receipt.isReturnCompleted = true
                    NotificationManager.shared.cancelReminders(for: receipt)
                } label: {
                    Label("Mark Returned", systemImage: "checkmark.circle")
                }
                .tint(.green)
            }
        }
    }
}
