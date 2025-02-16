//
//  AVCapturePhoto+unpack.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI
import AVKit

extension AVCapturePhoto {
    func unpack() -> Image? {
        guard
            let previewCGImage = previewCGImageRepresentation(),
            let metadataOrientation = metadata[String(kCGImagePropertyOrientation)] as? UInt32,
            let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation)
        else {
            return nil
        }

        let image = Image(
            decorative: previewCGImage,
            scale: 1,
            orientation: Image.Orientation(cgImageOrientation)
        )

        return image
    }
}

extension Image.Orientation {
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
