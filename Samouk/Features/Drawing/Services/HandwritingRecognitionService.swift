import Vision
import PencilKit
import UIKit

class HandwritingRecognitionService {
    static let shared = HandwritingRecognitionService()
    
    private init() {}
    
    func recognizeHandwriting(from drawing: PKDrawing, completion: @escaping (String?) -> Void) {
        // Konvertujemo PKDrawing u UIImage
        let bounds = CGRect(x: 0, y: 0, width: 500, height: 500)
        let image = drawing.image(from: bounds, scale: 1.0)
        
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        // Kreiranje zahteva za prepoznavanje teksta
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  let firstObservation = observations.first,
                  let firstCandidate = firstObservation.topCandidates(1).first else {
                completion(nil)
                return
            }
            
            completion(firstCandidate.string)
        }
        
        // Konfiguracija za prepoznavanje rukopisa
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
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
        return recognizedText.lowercased() == expectedLetter.lowercased()
    }
} 