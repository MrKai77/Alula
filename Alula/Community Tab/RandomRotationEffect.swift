//
//  RandomRotationEffect.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-16.
//

import SwiftUI

struct RandomRotationEffect: ViewModifier {
    let minRange: Double
    let maxRange: Double
    let rotation: Double

    init(minRange: Double, maxRange: Double) {
        self.minRange = minRange
        self.maxRange = maxRange
        self.rotation = Double.random(in: minRange...maxRange)
    }

    func body(content: Content) -> some View {
        content.rotationEffect(.degrees(rotation))
    }
}

extension View {
    func randomRotation(minRange: Double, maxRange: Double) -> some View {
        self.modifier(RandomRotationEffect(minRange: minRange, maxRange: maxRange))
    }
}
