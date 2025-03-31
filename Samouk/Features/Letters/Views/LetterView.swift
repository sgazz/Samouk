import SwiftUI
import PencilKit

struct LetterView: View {
    @State private var canvasView = PKCanvasView()
    @State private var currentLetter: String
    @State private var showingAnimation = false
    @State private var isChecking = false
    @State private var recognitionResult: RecognitionResult?
    
    @AppStorage("penColor") private var penColorString = "black"
    @AppStorage("penWidth") private var penWidth = 5.0
    @AppStorage("showGuideLines") private var showGuideLines = true
    
    private let handwritingService = HandwritingRecognitionService.shared
    private let sampleService = HandwritingSampleService.shared
    private let progressTracker = ProgressTracker.shared
    private let audioManager = AudioManager.shared
    
    init(letter: String? = nil) {
        _currentLetter = State(initialValue: letter ?? ProgressTracker.shared.getNextRecommendedLetter())
    }
    
    private var penColor: UIColor {
        switch penColorString {
            case "blue": return .systemBlue
            case "red": return .systemRed
            case "green": return .systemGreen
            default: return .black
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Napiši slovo: \(currentLetter)")
                .font(.system(size: 32, weight: .bold))
                .padding()
            
            ZStack {
                Color.white
                    .cornerRadius(15)
                    .shadow(radius: 5)
                
                if showGuideLines {
                    GuideLines()
                }
                
                DrawingCanvas(
                    canvasView: $canvasView,
                    penColor: penColor,
                    penWidth: penWidth
                ) { drawing in
                    audioManager.playSound(.stroke)
                }
                
                if showingAnimation {
                    GeometryReader { geometry in
                        LetterAnimationService.shared.createAnimatedPath(
                            for: LetterModel.letterA,
                            in: geometry.size
                        )
                    }
                    .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.width)
            .padding()
            
            // Povratne informacije o prepoznavanju
            RecognitionFeedbackView(
                isRecognizing: isChecking,
                confidence: recognitionResult?.confidence,
                recognizedText: recognitionResult?.text,
                expectedLetter: currentLetter
            )
            .padding(.horizontal)
            
            HStack(spacing: 30) {
                Button(action: {
                    canvasView.drawing = PKDrawing()
                    recognitionResult = nil
                }) {
                    VStack {
                        Image(systemName: "trash")
                            .font(.system(size: 24))
                        Text("Obriši")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
                
                Button(action: {
                    showingAnimation = true
                }) {
                    VStack {
                        Image(systemName: "play.circle")
                            .font(.system(size: 24))
                        Text("Prikaži")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                
                Button(action: checkDrawing) {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 24))
                        Text("Proveri")
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                }
            }
            .padding()
            .disabled(isChecking)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: showingAnimation) { oldValue, newValue in
            if newValue {
                // Resetujemo animaciju nakon što se završi
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showingAnimation = false
                }
            }
        }
    }
    
    private func checkDrawing() {
        isChecking = true
        recognitionResult = nil
        
        handwritingService.recognizeHandwriting(from: canvasView.drawing, for: currentLetter) { result in
            if let result = result {
                recognitionResult = result
                let isCorrect = handwritingService.validateDrawing(result.text, against: currentLetter)
                
                // Čuvamo primer rukopisa
                sampleService.saveSample(
                    letter: currentLetter,
                    drawing: canvasView.drawing,
                    confidence: result.confidence,
                    wasSuccessful: isCorrect
                )
                
                audioManager.playSound(isCorrect ? .correct : .incorrect)
                progressTracker.recordAttempt(for: currentLetter, wasSuccessful: isCorrect)
                
                if isCorrect {
                    // Prelazak na sledeće slovo nakon kratke pauze
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        currentLetter = progressTracker.getNextRecommendedLetter()
                        canvasView.drawing = PKDrawing()
                        recognitionResult = nil
                    }
                }
            }
            
            isChecking = false
        }
    }
}

struct LetterView_Previews: PreviewProvider {
    static var previews: some View {
        LetterView(letter: "A")
    }
} 