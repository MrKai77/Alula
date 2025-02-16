//
//  ViewfinderView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct ViewfinderView: View {
    @ObservedObject var model: AlulaModel = .shared

    var body: some View {
        Group {
            Color.clear
                .overlay {
                    if let image = model.viewfinderImage {
                        image
                            .resizable()
                            .scaledToFill()
                    }
                }
                .background(.quaternary)
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(lineWidth: 1)
                        .foregroundStyle(.quaternary)
                }
        }
    }
}
