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
                .background {
                    Image(.background)
                        .resizable()
                        .scaledToFill()
                }
        }
    }
}

struct ContentView: View {
    @ObservedObject var model: AlulaModel = .shared

    var body: some View {
        TabView(selection: $model.tab) {
            Tab("Identify", systemImage: "camera", value: AlulaTab.identify) {
                IdentifyView()
                    .background { BackgroundView() }
            }

            Tab("Catalog", systemImage: "book", value: AlulaTab.catalog) {
                CatalogView()
                    .background { BackgroundView() }
            }

            Tab("Community", systemImage: "person.3", value: AlulaTab.community) {
                CommunityView()
                    .background { BackgroundView() }
            }

            Tab("Profile", systemImage: "person", value: AlulaTab.profile) {
                ProfileView()
                    .background { BackgroundView() }
            }
        }
        .sheet(isPresented: $model.isShowingInfoSheet) {
            if let asset = model.infoSheetSelectedAsset {
                BirdSheetView(asset: asset)
            }
        }
    }
}

struct BackgroundView: View {
    var body: some View {
        Image(.background)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .overlay(.thinMaterial)
    }
}

#Preview {
    ContentView()
}
