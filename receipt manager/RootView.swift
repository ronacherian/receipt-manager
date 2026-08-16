//
//  RootView.swift
//  receipt manager
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ScanView()
                .tabItem { Label("Scan", systemImage: "doc.viewfinder") }
            ManageView()
                .tabItem { Label("Manage", systemImage: "list.bullet") }
        }
    }
}
