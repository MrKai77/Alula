//
//  CatalogView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct CatalogView: View {
    @ObservedObject var model: AlulaModel = .shared

    private static let spacing: CGFloat = 2
    private let columns = [
        GridItem(.flexible(), spacing: Self.spacing),
        GridItem(.flexible(), spacing: Self.spacing),
        GridItem(.flexible(), spacing: Self.spacing)
    ]

    var body: some View {
        NavigationStack {
            if model.takenImages.isEmpty {
                ContentUnavailableView(
                    "No images taken",
                    image: "photo.badge.exclamationmark",
                    description: Text("Birds will appear here after you take photos!")
                )
            } else {
                Form {
                    Section {
                        List(model.takenImages) { asset in
                            AssetView(asset: asset)
                        }
                    }
                    .listRowBackground(Color.primary.opacity(0.125))
                    .listRowSeparatorTint(.primary.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .background { BackgroundView() }
                .navigationTitle("Catalogue")
            }
        }
    }
}

struct AssetView: View {
    @ObservedObject var model: AlulaModel = .shared

    let asset: CaptureAsset
    @State private var isSheetPresented: Bool = false

    var body: some View {
        Button {
            model.infoSheetSelectedAsset = asset
            model.isShowingInfoSheet = true
        } label: {
            HStack {
                Rectangle()
                    .frame(width: 64, height: 64)
                    .overlay {
                        asset.image
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(.rect(cornerRadius: 6))

                VStack(alignment: .leading) {
                    Text(asset.bird_name)
                        .fontWeight(.semibold)

                    Text(asset.bird_description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .clipped()
        .contentShape(.rect)
    }
}
