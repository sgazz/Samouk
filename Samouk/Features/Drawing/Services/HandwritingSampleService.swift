import Foundation
import PencilKit
import UIKit

struct HandwritingSample: Codable {
    let letter: String
    let drawing: Data
    let confidence: Double
    let timestamp: Date
    let wasSuccessful: Bool
}

class HandwritingSampleService {
    static let shared = HandwritingSampleService()
    
    private let userDefaults = UserDefaults.standard
    private let samplesKey = "handwritingSamples"
    private let maxSamplesPerLetter = 10
    
    private var samples: [String: [HandwritingSample]] {
        get {
            guard let data = userDefaults.data(forKey: samplesKey),
                  let samples = try? JSONDecoder().decode([String: [HandwritingSample]].self, from: data) else {
                return [:]
            }
            return samples
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: samplesKey)
            }
        }
    }
    
    private init() {}
    
    func saveSample(letter: String, drawing: PKDrawing, confidence: Double, wasSuccessful: Bool) {
        // Konvertujemo PKDrawing u Data
        let drawingData = drawing.dataRepresentation()
        
        let sample = HandwritingSample(
            letter: letter,
            drawing: drawingData,
            confidence: confidence,
            timestamp: Date(),
            wasSuccessful: wasSuccessful
        )
        
        var letterSamples = samples[letter] ?? []
        
        // Dodajemo novi primer
        letterSamples.append(sample)
        
        // Sortiramo po pouzdanosti i zadržavamo samo najbolje
        letterSamples.sort { $0.confidence > $1.confidence }
        if letterSamples.count > maxSamplesPerLetter {
            letterSamples = Array(letterSamples.prefix(maxSamplesPerLetter))
        }
        
        samples[letter] = letterSamples
    }
    
    func getSamples(for letter: String) -> [HandwritingSample] {
        return samples[letter] ?? []
    }
    
    func getAverageConfidence(for letter: String) -> Double? {
        let letterSamples = samples[letter] ?? []
        guard !letterSamples.isEmpty else { return nil }
        
        let successfulSamples = letterSamples.filter { $0.wasSuccessful }
        guard !successfulSamples.isEmpty else { return nil }
        
        return successfulSamples.reduce(0) { $0 + $1.confidence } / Double(successfulSamples.count)
    }
    
    func getAdaptiveThreshold(for letter: String) -> Double {
        if let averageConfidence = getAverageConfidence(for: letter) {
            // Koristimo 80% prosečne pouzdanosti uspešnih primera
            return max(0.5, averageConfidence * 0.8)
        }
        return 0.5 // Podrazumevani prag
    }
    
    func clearSamples() {
        samples = [:]
    }
} 