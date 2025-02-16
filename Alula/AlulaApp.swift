//
//  AlulaApp.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

@main
struct AlulaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @ObservedObject var model: AlulaModel = .shared

    var body: some View {
        TabView(selection: $model.tab) {
            Tab("Identify", systemImage: "camera", value: AlulaTab.identify) {
                IdentifyView()
            }
        }
    }
}
