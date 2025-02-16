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
        if model.takenImages.isEmpty {
            ContentUnavailableView(
                "No images taken",
                image: "photo.badge.exclamationmark",
                description: Text("Birds will appear here after you take photos!")
            )
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Self.spacing) {
                    ForEach(model.takenImages, id: \.id) { asset in
                        Button {
                            print("A")
                        } label: {
                            asset.image
                                .resizable()
                                .scaledToFill()
                        }
                        .clipped()
                        .contentShape(.rect)
                    }
                }
            }
        }
    }
}
