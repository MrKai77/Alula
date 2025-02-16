//
//  CIImage+Image.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

extension CIImage {
    var uiImage: UIImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
