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
        VStack {
            ViewfinderView()

            if let prediction = model.prediction {
                Text(prediction)
            }
        }
        .padding()
    }
}
