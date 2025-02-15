/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Vision extension that adds a `confidencePercentageString` property to VNClassificationObservation instances.
*/

import Vision

extension VNClassificationObservation {
    /// Generates a string of the observation's confidence as a percentage.
    var confidencePercentageString: String {
        let percentage = confidence * 100

        switch percentage {
            case 100.0...:
                return "100%"
            case 10.0..<100.0:
                return String(format: "%2.1f", percentage)
            case 1.0..<10.0:
                return String(format: "%2.1f", percentage)
            case ..<1.0:
                return String(format: "%1.2f", percentage)
            default:
                return String(format: "%2.1f", percentage)
        }
    }
}
