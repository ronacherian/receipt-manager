//
//  receipt_managerApp.swift
//  receipt manager
//
//  Created by RON ABRAHAM CHERIAN on 8/16/26.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct receipt_managerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Receipt.self,
            ReceiptPage.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.racllc.receipt-manager")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
