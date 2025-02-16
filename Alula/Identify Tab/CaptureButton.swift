//
//  CaptureButton.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct CaptureButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var model: AlulaModel = .shared

    var body: some View {
        Button {
            model.capturePhoto()
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(lineWidth: 4)

                Circle()
                    .inset(by: 6)
            }
            .foregroundStyle(.white)
            .frame(width: 72, height: 72)
        }
        .disabled(model.prediction?.birdName == nil)
        .opacity(model.prediction?.birdName == nil ? 0.5 : 1)
    }
}
