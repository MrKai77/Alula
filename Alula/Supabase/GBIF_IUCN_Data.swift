//
//  GBIF_IUCN_Data.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-16.
//

import SwiftUI

struct GBIF_IUCN_Data: Codable {
    let bird_id: Int
//    let name: String?
    let scientific_name: String?
    let gbif_id: Int?
    let iucn_status: IUCN_Status?

    enum IUCN_Status: String, Codable {
        case leastConcern = "LEAST_CONCERN"
        case nearThreatened = "NEAR_THREATENED"
        case vulnerable = "VULNERABLE"
        case endangered = "ENDANGERED"
        case criticallyEndangered = "CRITICALLY_ENDANGERED"
        case extinctInTheWild = "EXTINCT_IN_THE_WILD"
        case unknown = "Not Available"

        var humanReadable: String {
            switch self {
            case .leastConcern:
                return "Least Concern"
            case .nearThreatened:
                return "Near Threatened"
            case .vulnerable:
                return "Vulnerable"
            case .endangered:
                return "Endangered"
            case .criticallyEndangered:
                return "Critically Endangered"
            case .extinctInTheWild:
                return "Extinct in the Wild"
            case .unknown:
                return "Not Available"
            }
        }

        var glowingDots: Int {
            switch self {
            case .leastConcern:
                return 1
            case .nearThreatened:
                return 2
            case .vulnerable:
                return 3
            case .endangered:
                return 4
            case .criticallyEndangered:
                return 5
            case .extinctInTheWild:
                return 6
            case .unknown:
                return 0
            }
        }

        var color: Color {
            switch self {
            case .leastConcern:
                return .green
            case .nearThreatened:
                return .yellow
            case .vulnerable:
                return .orange
            case .endangered:
                return .red
            case .criticallyEndangered:
                return .purple
            case .extinctInTheWild:
                return .gray
            case .unknown:
                return .gray
            }
        }
    }
}
