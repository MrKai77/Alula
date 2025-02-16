//
//  CGImagePropertyOrientation+UIImageOrientation.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import UIKit
import ImageIO

extension CGImagePropertyOrientation {
    /// Converts an image orientation to a Core Graphics image property orientation.
    /// - Parameter orientation: A `UIImage.Orientation` instance.
    ///
    /// The two orientation types use different raw values.
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
            case .up: self = .up
            case .down: self = .down
            case .left: self = .left
            case .right: self = .right
            case .upMirrored: self = .upMirrored
            case .downMirrored: self = .downMirrored
            case .leftMirrored: self = .leftMirrored
            case .rightMirrored: self = .rightMirrored
            @unknown default: self = .up
        }
    }
}
