//
//  AlulaModel.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

enum AlulaTab: String, Codable {
    case identify, catalog
}

@MainActor
class AlulaModel: ObservableObject {
    static let shared: AlulaModel = .init()

    @Published var tab: AlulaTab = .identify {
        didSet {
            handleTabChange()
        }
    }

    private var lastPredictionUpdate: Date = .distantPast
    private(set) var prediction: String?

    @Published private(set) var viewfinderImage: Image?
    @Published private(set) var takenImages: [Image] = []

    private let skeleton = AlulaSkeleton()
    private let camera: Camera = .init()

    private init() {
        prepareForCameraOutput()
        handleTabChange()
    }

    func handleTabChange() {
        if tab == .identify {
            startCamera()
        } else {
            stopCamera()
        }
    }
}

// MARK: - Image Classification

extension AlulaModel {
    private func classifyImage(_ image: UIImage) -> String? {
        guard Date.now.timeIntervalSince(lastPredictionUpdate) > 1 else {
            return prediction
        }

        var name: String? = nil

        do {
            guard let prediction = try skeleton.makePredictions(for: image).first else {
                print("Vision was unable to make a prediction")
                return nil
            }

            guard Double(prediction.confidencePercentage) ?? 100.0 >= 75.0 else {
                print("Confidence was too low to make a prediction")
                return nil
            }

            print("Prediction: \(prediction.classification) - \(prediction.confidencePercentage)")

            name = PredictionConverter.convert(from: Int(prediction.classification) ?? 0)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }

        lastPredictionUpdate = Date.now

        return name
    }
}

// MARK: - Camera

extension AlulaModel {
    func startCamera() {
        Task {
            await camera.start()
        }
    }

    func stopCamera() {
        Task {
            await camera.stop()
        }
    }

    func capturePhoto() {
        camera.takePhoto()
    }

    private func prepareForCameraOutput() {
        Task {
            async let viewfinderTask: () = handleViewfinder()
            async let cameraPhotosTask: () = handleTakenPhotos()
            _ = await (viewfinderTask, cameraPhotosTask)
        }
    }

    private func handleViewfinder() async {
        let imageStream = camera.previewStream.map(\.uiImage)

        for await image in imageStream {
            Task { @MainActor in
                if let image {
                    viewfinderImage = Image(uiImage: image)
                    prediction = classifyImage(image)
                } else {
                    viewfinderImage = nil
                }
            }
        }
    }

    private func handleTakenPhotos() async {
        let unpackedPhotoStream = camera.photoStream.compactMap { $0.unpack() }

        for await photo in unpackedPhotoStream {
            Task { @MainActor in
                takenImages.append(photo)
            }
        }
    }
}
