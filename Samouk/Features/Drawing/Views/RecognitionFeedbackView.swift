import SwiftUI
import PencilKit

struct RecognitionFeedbackView: View {
    let isRecognizing: Bool
    let confidence: Double?
    let recognizedText: String?
    let expectedLetter: String
    
    var body: some View {
        VStack(spacing: 10) {
            if isRecognizing {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Prepoznavanje...")
                        .foregroundColor(.secondary)
                }
            } else if let text = recognizedText {
                HStack(spacing: 15) {
                    // Prikaz prepoznatog teksta
                    Text("Prepoznato: \(text)")
                        .font(.headline)
                    
                    // Indikator pouzdanosti
                    if let confidence = confidence {
                        ConfidenceIndicator(confidence: confidence)
                    }
                    
                    // Indikator tačnosti
                    AccuracyIndicator(
                        recognized: text,
                        expected: expectedLetter
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}

struct ConfidenceIndicator: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "chart.bar.fill")
            Text("\(Int(confidence * 100))%")
                .font(.subheadline)
        }
        .foregroundColor(confidenceColor)
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: return .green
        case 0.6...: return .yellow
        default: return .red
        }
    }
}

struct AccuracyIndicator: View {
    let recognized: String
    let expected: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
            Text(isCorrect ? "Tačno" : "Netačno")
                .font(.subheadline)
        }
        .foregroundColor(isCorrect ? .green : .red)
    }
    
    private var isCorrect: Bool {
        recognized.uppercased() == expected.uppercased()
    }
}

#Preview {
    VStack(spacing: 20) {
        RecognitionFeedbackView(
            isRecognizing: true,
            confidence: nil,
            recognizedText: nil,
            expectedLetter: "A"
        )
        
        RecognitionFeedbackView(
            isRecognizing: false,
            confidence: 0.85,
            recognizedText: "A",
            expectedLetter: "A"
        )
        
        RecognitionFeedbackView(
            isRecognizing: false,
            confidence: 0.65,
            recognizedText: "B",
            expectedLetter: "A"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 