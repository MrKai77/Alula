//
//  AlulaSkeleton.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import Vision
import UIKit

class AlulaSkeleton {
    private static let imageClassifier = createImageClassifier()

    static func createImageClassifier() -> VNCoreMLModel {
        let imageClassifierWrapper = try? Alula_Skeleton(configuration: .init())

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("Failed to create an image classifier model instance")
        }

        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifier.model) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }

        return imageClassifierVisionModel
    }

    private func createImageClassificationRequest() -> VNImageBasedRequest {
        let imageClassificationRequest = VNCoreMLRequest(
            model: AlulaSkeleton.imageClassifier,
            completionHandler: nil  // We'll handle the results directly instead
        )

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }

    func makePredictions(for photo: UIImage) throws -> [Prediction] {
        let orientation = CGImagePropertyOrientation(photo.imageOrientation)

        guard let photoImage = photo.cgImage else {
            throw PredictionError.invalidImage
        }

        let imageClassificationRequest = createImageClassificationRequest()
        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)

        try handler.perform([imageClassificationRequest])

        guard let results = imageClassificationRequest.results else {
            throw PredictionError.noResults
        }

        guard let observations = results as? [VNClassificationObservation] else {
            throw PredictionError.invalidResults
        }

        return observations.map { observation in
            Prediction(
                classification: observation.identifier,
                confidencePercentage: observation.confidencePercentageString
            )
        }
    }
}

extension AlulaSkeleton {
    struct Prediction {
        let classification: String
        let confidencePercentage: String

        var birdName: String? {
            PredictionConverter.convert(from: Int(classification) ?? 0)
        }
    }

    enum PredictionError: Error {
        case invalidImage
        case noResults
        case invalidResults
    }
}
