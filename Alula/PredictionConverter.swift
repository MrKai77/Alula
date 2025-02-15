//
//  PredictionConverter.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import SwiftUI

class PredictionConverter {
    private init() {}

    private static let birdsCache: [Int: String] = {
        guard
            let url = Bundle.main.url(forResource: "bird_classification", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let classifications = try? JSONDecoder().decode([Int: String].self, from: data)
        else {
            fatalError("Failed to load data from file: bird_classification.json")
        }

        return classifications
    }()

    static func convert(from id: Int) -> String? {
        return birdsCache.first { $0.key == id }?.value
    }
}
