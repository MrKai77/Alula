//
//  BirdSheetView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-16.
//

import SwiftUI

struct BirdSheetView: View {
    let asset: CaptureAsset

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Color.clear
                    .overlay {
                        asset.image
                            .resizable()
                            .scaledToFill()
                    }
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.rect)

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(asset.bird_name)
                            .fontWeight(.semibold)
                            .font(.title)

                        if let scientific_name = asset.scientific_name {
                            Text(scientific_name)
                                .font(.system(.title3, design: .serif))
                                .italic()
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(alignment: .top) {
                        IUCN_View(status: asset.iucn_red_list)

                        Spacer(minLength: .zero)

                        Text("ID #\(asset.bird_id)")
                            .monospaced()
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(asset.bird_description)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                }
                .padding(.horizontal, 12)
            }
        }
        .presentationBackground {
            BackgroundView()
        }
    }
}

struct IUCN_View: View {
    let status: GBIF_IUCN_Data.IUCN_Status

    var body: some View {
        VStack(alignment: .leading) {
            Text(status.humanReadable)
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(0 ..< 6, id: \.self) { i in
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundStyle(.tertiary)
                        .overlay {
                            if i < status.glowingDots {
                                Circle()
                                    .foregroundStyle(status.color)
                                    .shadow(color: status.color, radius: 4)
                                    .frame(width: 4, height: 4)
                            }
                        }
                }
            }
        }
    }
}

struct BirdSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BirdSheetView(
            asset: .init(
                image: Image(.alula),
                data: .init(
                    bird_id: 0,
                    bird_name: "Bird",
                    bird_description: "No Description"
                ),
                iucnData: .init(
                    bird_id: 0,
                    scientific_name: "Birdus Humongous",
                    gbif_id: 0,
                    iucn_status: .endangered
                )
            )
        )
    }
}
