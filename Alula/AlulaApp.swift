//
//  AlulaApp.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

@main
struct AlulaApp: App {
    @ObservedObject var model: AlulaModel = .shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
