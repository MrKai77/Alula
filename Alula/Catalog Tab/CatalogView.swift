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
                .navigationTitle("Catalog")
            }
        }
    }
}

struct AssetView: View {
    @ObservedObject var model: AlulaModel = .shared

    let asset: TakenPhoto
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
                    Text((asset.data.bird_name ?? PredictionConverter.convert(from: asset.data.bird_id)) ?? "Unknown Bird")
                        .fontWeight(.semibold)

                    if let description = asset.data.bird_description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                }
                .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .clipped()
        .contentShape(.rect)
    }
}

struct BirdSheetView: View {
    let asset: TakenPhoto

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Color.clear
                    .overlay {
                        asset.image
                            .resizable()
                            .scaledToFill()
                    }
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.rect)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text((asset.data.bird_name ?? PredictionConverter.convert(from: asset.data.bird_id)) ?? "Unknown Bird")
                            .fontWeight(.semibold)

                        Spacer(minLength: .zero)

                        Text("\(asset.data.bird_id)")
                            .monospaced()
                            .bold()
                            .foregroundStyle(.quaternary)
                    }
                    .font(.title)

                    if let description = asset.data.bird_description {
                        Text(description)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .presentationBackground {
            BackgroundView()
        }
    }
}
