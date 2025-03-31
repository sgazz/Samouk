import Vision
import PencilKit
import UIKit
import CoreImage

struct RecognitionResult {
    let text: String
    let confidence: Double
}

class HandwritingRecognitionService {
    static let shared = HandwritingRecognitionService()
    private let sampleService = HandwritingSampleService.shared
    private let context = CIContext()
    
    private init() {}
    
    private func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        // Konvertujemo u CIImage
        let ciImage = CIImage(cgImage: cgImage)
        
        // Poboljšavamo kontrast
        let contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        contrastFilter?.setValue(1.2, forKey: kCIInputContrastKey)
        
        // Smanjujemo šum
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(contrastFilter?.outputImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(0.5, forKey: kCIInputRadiusKey)
        
        // Poboljšavamo oštrinu
        let sharpenFilter = CIFilter(name: "CISharpenLuminance")
        sharpenFilter?.setValue(blurFilter?.outputImage, forKey: kCIInputImageKey)
        sharpenFilter?.setValue(0.5, forKey: kCIInputSharpnessKey)
        
        guard let outputImage = sharpenFilter?.outputImage,
              let processedCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: processedCGImage)
    }
    
    func recognizeHandwriting(from drawing: PKDrawing, for letter: String, completion: @escaping (RecognitionResult?) -> Void) {
        // Konvertujemo PKDrawing u UIImage sa boljom rezolucijom
        let bounds = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        let image = drawing.image(from: bounds, scale: 2.0)
        
        // Predprocesiranje slike
        guard let processedImage = preprocessImage(image),
              let cgImage = processedImage.cgImage else {
            completion(nil)
            return
        }
        
        // Kreiranje zahteva za prepoznavanje teksta
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // Uzimamo sve kandidate i sortiramo ih po pouzdanosti
            let candidates = observations.flatMap { observation in
                observation.topCandidates(3).map { candidate in
                    RecognitionResult(
                        text: candidate.string,
                        confidence: Double(candidate.confidence)
                    )
                }
            }
            .sorted { $0.confidence > $1.confidence }
            
            // Filtriranje i normalizacija rezultata
            let filteredCandidates = candidates.filter { result in
                // Koristimo adaptivni prag pouzdanosti
                let threshold = self?.sampleService.getAdaptiveThreshold(for: letter) ?? 0.5
                return result.confidence > threshold &&
                       result.text.count <= 2 &&
                       !result.text.contains(where: { !$0.isLetter })
            }
            
            // Uzimamo najbolji rezultat
            if let bestMatch = filteredCandidates.first {
                completion(RecognitionResult(
                    text: bestMatch.text.uppercased(),
                    confidence: bestMatch.confidence
                ))
            } else {
                completion(nil)
            }
        }
        
        // Konfiguracija za prepoznavanje rukopisa
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["sr-Latn"]
        request.minimumTextHeight = 0.01
        
        // Kreiranje handlera za procesiranje slike
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error: \(error)")
            completion(nil)
        }
    }
    
    func validateDrawing(_ recognizedText: String, against expectedLetter: String) -> Bool {
        // Normalizacija teksta pre poređenja
        let normalizedRecognized = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedExpected = expectedLetter.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Direktno poređenje
        if normalizedRecognized == normalizedExpected {
            return true
        }
        
        // Provera sličnih karaktera
        let similarCharacters: [String: [String]] = [
            "A": ["4"],
            "B": ["8"],
            "I": ["1", "l"],
            "O": ["0"],
            "S": ["5"],
            "Z": ["2"]
        ]
        
        // Provera sličnih karaktera
        if let similar = similarCharacters[normalizedExpected],
           similar.contains(normalizedRecognized) {
            return true
        }
        
        // Provera Levenshtein distance za slične slova
        let levenshteinDistance = calculateLevenshteinDistance(
            between: normalizedRecognized,
            and: normalizedExpected
        )
        
        // Ako je razlika mala (1 karakter), možda je greška u prepoznavanju
        if levenshteinDistance <= 1 {
            return true
        }
        
        // Provera rotacije slova (npr. "N" i "Z")
        if isRotatedVersion(normalizedRecognized, of: normalizedExpected) {
            return true
        }
        
        return false
    }
    
    private func calculateLevenshteinDistance(between s1: String, and s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        
        var matrix = Array(repeating: Array(repeating: 0, count: s2Array.count + 1), count: s1Array.count + 1)
        
        // Inicijalizacija prve kolone
        for i in 0...s1Array.count {
            matrix[i][0] = i
        }
        
        // Inicijalizacija prvog reda
        for j in 0...s2Array.count {
            matrix[0][j] = j
        }
        
        // Izračunavanje matrice
        for i in 0..<s1Array.count {
            for j in 0..<s2Array.count {
                if s1Array[i] == s2Array[j] {
                    matrix[i + 1][j + 1] = matrix[i][j]
                } else {
                    matrix[i + 1][j + 1] = min(
                        matrix[i][j] + 1,     // zamena
                        matrix[i + 1][j] + 1, // brisanje
                        matrix[i][j + 1] + 1  // umetanje
                    )
                }
            }
        }
        
        return matrix[s1Array.count][s2Array.count]
    }
    
    private func isRotatedVersion(_ s1: String, of s2: String) -> Bool {
        let rotatedPairs: [(String, String)] = [
            ("N", "Z"),
            ("Z", "N"),
            ("M", "W"),
            ("W", "M")
        ]
        
        return rotatedPairs.contains { (first, second) in
            (s1 == first && s2 == second) || (s1 == second && s2 == first)
        }
    }
} 