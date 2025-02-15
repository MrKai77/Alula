//
//  ContentView.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: AlulaModel = .shared

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")

            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }

            if let prediction = model.prediction {
                Text(prediction)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
