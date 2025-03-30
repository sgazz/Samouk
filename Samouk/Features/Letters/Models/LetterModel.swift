import Foundation
import CoreGraphics

struct LetterModel: Identifiable {
    let id = UUID()
    let character: String
    let strokePoints: [CGPoint]
    let strokeOrder: [[Int]]  // Indeksi tačaka za svaki potez
    
    static let alphabet: [String] = "ABCČĆDĐEFGHIJKLMNOPQRSŠTUVWXYZŽ".map { String($0) }
    
    init(character: String, strokePoints: [CGPoint], strokeOrder: [[Int]]) {
        self.character = character
        self.strokePoints = strokePoints
        self.strokeOrder = strokeOrder
    }
    
    // Primer definicije slova A
    static let letterA = LetterModel(
        character: "A",
        strokePoints: [
            CGPoint(x: 0.5, y: 1.0),   // Početak prvog poteza
            CGPoint(x: 0.25, y: 0.0),  // Kraj prvog poteza
            CGPoint(x: 0.75, y: 0.0),  // Početak drugog poteza
            CGPoint(x: 0.5, y: 1.0),   // Kraj drugog poteza
            CGPoint(x: 0.3, y: 0.5),   // Početak horizontalne linije
            CGPoint(x: 0.7, y: 0.5)    // Kraj horizontalne linije
        ],
        strokeOrder: [
            [0, 1],     // Prvi potez
            [2, 3],     // Drugi potez
            [4, 5]      // Treći potez (horizontalna linija)
        ]
    )
    
    // Funkcija za normalizaciju tačaka u odnosu na veličinu prostora za crtanje
    func normalizedPoints(for size: CGSize) -> [CGPoint] {
        return strokePoints.map { point in
            CGPoint(
                x: point.x * size.width,
                y: point.y * size.height
            )
        }
    }
} 