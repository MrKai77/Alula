//
//  AlulaModel.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

@MainActor
class AlulaModel: ObservableObject {
    static let shared: AlulaModel = .init()

    private(set) var image: UIImage?
    private(set) var prediction: String?

    private let skeleton = AlulaSkeleton()

    private init() {
//        let image = UIImage(resource: ._1D57B5C3095A4040A8B2Ce02E3Fb00D9)
//        self.image = image
//
//        classifyImage(image)
    }

    private func classifyImage(_ image: UIImage) {
        do {
            let prediction = try skeleton.makePredictions(for: image)
            print(prediction)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
}
