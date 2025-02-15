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
//        let image = UIImage(resource: ._1C27D219D5Fb470B99054E0De2Cf39E6)
//        self.image = image
//
//        print(classifyImage(image))
    }

    private func classifyImage(_ image: UIImage) -> String? {
        do {
            guard let prediction = try skeleton.makePredictions(for: image).first else {
                print("Vision was unable to make a prediction")
                return nil
            }

            let name = PredictionConverter.convert(from: Int(prediction.classification) ?? 0)

            return name
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }

        return nil
    }
}
