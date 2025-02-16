//
//  AlulaModel.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

enum AlulaTab: String, Codable {
    case identify, catalog, community, profile
}

struct TakenPhoto: Identifiable {
    let id = UUID()
    let image: Image
    let data: BirdDescription

    init(image: Image, data: BirdDescription) {
        self.image = image
        self.data = data
    }
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
    private(set) var prediction: AlulaSkeleton.Prediction?
    private(set) var data: BirdDescription?

    @Published var infoSheetSelectedAsset: TakenPhoto?
    @Published var isShowingInfoSheet: Bool = false
    @Published private(set) var viewfinderImage: Image?
    @Published private(set) var takenImages: [TakenPhoto] = []

    private let skeleton = AlulaSkeleton()
    private let camera: Camera = .init()

    private init() {
        prepareForCameraOutput()
        handleTabChange()

        Task {
//            print(try? await SupabaseBridge.shared.loadAchievements())
//            print(try? await SupabaseBridge.shared.loadUsers())
//            print(try? await SupabaseBridge.shared.loadDescription(birdId: 1))
        }
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
    private func classifyImage(_ image: UIImage) -> AlulaSkeleton.Prediction? {
        guard Date.now.timeIntervalSince(lastPredictionUpdate) > 1 else {
            return prediction
        }

        var prediction: AlulaSkeleton.Prediction? = nil

        do {
            guard let bird = try skeleton.makePredictions(for: image).first else {
                print("Vision was unable to make a prediction")
                return nil
            }

            guard Double(bird.confidencePercentage) ?? 100.0 >= 60.0 else {
                return nil
            }

            print("Prediction: \(bird.classification) - \(bird.confidencePercentage)")

            prediction = bird
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }

        lastPredictionUpdate = Date.now

        return prediction
    }

    private func getData(for prediction: AlulaSkeleton.Prediction) async -> BirdDescription {
        do {
            if let description = try await SupabaseBridge.shared.loadDescription(
                birdId: Int(prediction.classification) ?? 0
            ) {
                return description
            }
        } catch {
            print("Failed to load bird data: \(error)")
        }

        return .init(
            bird_id: Int(prediction.classification) ?? 0,
            bird_name: prediction.birdName ?? "Bird",
            bird_description: "No description available."
        )
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

                    if let prediction {
                        data = await getData(for: prediction)
                    }
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
                if let data {
                    let takenPhoto = TakenPhoto(
                        image: photo,
                        data: data
                    )

                    takenImages.append(takenPhoto)

                    infoSheetSelectedAsset = takenPhoto
                    isShowingInfoSheet = true
                }
            }
        }
    }
}
