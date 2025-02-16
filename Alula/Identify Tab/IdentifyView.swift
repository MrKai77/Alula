//
//  IdentifyView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct IdentifyView: View {
    @ObservedObject var model: AlulaModel = .shared

    var body: some View {
        VStack(spacing: 12) {
            Text(model.prediction?.birdName ?? "Finding bird…")
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .font(.footnote)
                .fontWeight(.semibold)
                .clipped()
                .background(.quaternary, in: .capsule)
                .overlay {
                    Capsule()
                        .strokeBorder(.quaternary, lineWidth: 1)
                }
                .animation(.snappy(duration: 0.25), value: model.prediction?.birdName ?? "")

            ViewfinderView()

            CaptureButton()
                .animation(.snappy(duration: 0.25), value: model.prediction?.birdName ?? "")
        }
        .padding()
    }
}
